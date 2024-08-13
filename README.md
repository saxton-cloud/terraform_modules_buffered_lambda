# buffered_lambda

> lambda with input and dead-letter queues

## general configuration

- **name** - _str_ - name of the component
- **qualifier** - _str_ - value used to distinguish one instance of this component from another in one or more aws accounts ( e.g. 'environment', branch, user, etc )
- **revision** - _str_ - version of the component ( e.g. commit hash, build id, semver, etc)
- **kms_key** - _object_ - optional reference to an existing KMS key resource/data to use for bucket encryption. a dedicated key will be created and used if a value is not supplied.
- **maximum_concurrency** - _number_ - maximum number of concurrent lambda instances servicing the input buffer ( defaults to 100 )
- **memory_size** - _number_ - amount of memory allocated ( MiB ) to each lambda instance ( defaults to 128 )
- **timeout** - _number_ - amount of time, in seconds, the lambda is permitted to execute ( defaults to 30 )

## input buffer configuration

- **batch_size** - _number_ - maximum number of records to send as batch per function invocation ( defaults to 10 )
- **max_batch_window_seconds** - _number_ - amount of time, in seconds, lambda will wait to accumulate records before sending batch to function invocation ( defaults to 0 with max 300 seconds )
- **checkpoint_support** - _bool_ - enables [AWS lambda checkpointing](https://docs.aws.amazon.com/prescriptive-guidance/latest/lambda-event-filtering-partial-batch-responses-for-sqs/benefits-partial-batch-responses.html) feature _( this affects the lambda's required response structure )_

```hcl
module "your_component" {
  source      = "https://github.com/saxton-cloud/terraform_modules_buffered_lambda.git"
  name        = var.name
  description = "some description of the purpose of your_component"
  subsystem   = var.subsystem
  qualifier   = var.qualifier
  revision    = var.revision

  memory_size = 512
  timeout     = 180
}
```

## security

### policy

though this module will ensure your lambda has the appropriate access to all resources created by the module, you will likely need to grant your lambda access to additional resources ( e.g. s3 buckets, kinesis streams, etc ). to do this, you specify a serialised IAM poliy object for the `policy` attribute

```hcl
module "your_component" {
  source      = "https://github.com/saxton-cloud/terraform_modules_buffered_lambda.git"
  name        = var.name
  ...
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["kinesis:PutRecords"]
        Resource = [
          aws_kinesis_stream.your_resource.arn
        ]
      }
    ]
  })
}
```

### assume role

should you need to permit additional principals the ability to assume your lambda's execution role, you can override the default using the `assume_role_policy` attribute

```hcl
module "your_component" {
  source      = "https://github.com/saxton-cloud/terraform_modules_buffered_lambda.git"
  name        = var.name
  ...
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = [
            "lambda.amazonaws.com",
            "someother-service.amazonaws.com"
          ]
        }
        Action = ["sts:AssumeRole"]
      }
    ]
  })
}
```

## vpc hosting

to host your lambda within a vpc, you must provide the `vpc_config` block, specifying the relavant information

### vpc_config settings

- **subnet_ids** - _list(str)_ - list of subnet ids to host the lambda instances
- **security_group_ids** - _list(str)_ - security group ids to associate with the lambda

```hcl

module "your_component" {
  source      = "https://github.com/saxton-cloud/terraform_modules_buffered_lambda.git"
  name        = var.name
  ...
  vpc_config = {
    subnet_ids = [<your_vpc_subnet_ids_here>]
    security_group_ids = [<your_security_group_ids_here>]
  }
}
```

## environment variable configuration

environment variables may be specified using the `environment` attribute

```hcl
module "your_component" {
  source      = "https://github.com/saxton-cloud/terraform_modules_buffered_lambda.git"
  name        = var.name
  ...

  environment = {
    POWERTOOLS_LOGGER_LOG_EVENT = "False"
    POWERTOOLS_SERVICE_NAME     = var.name
    LOG_LEVEL                   = "INFO"
    REVISION                    = var.revision
  }
}
```

## shared elastic container repository

there are occasions where you may need to associate multiple lambdas with a single image, such as in the case of StepFunctions or ECS tasks

in this case, your project will provision it's own ECR and have the lambda module's use this instead of creating their own

- **command** - _list(string)_ - commmand override
- **entry_point** - _list(string)_ - (optional) entrypoint override
- **working_directory** - _string_ - (optional) working directory override


```hcl
resource "aws_ecr_repository" "common" {
  name                 = replace("${local.name_prefix}-${var.name}", "_", "-")
  image_tag_mutability = "MUTABLE"
  force_delete         = true
  image_scanning_configuration {
    scan_on_push = true
  }
  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = aws_kms_key.encryption.arn
  }
}

module "component_one" {
  source                  = "https://github.com/saxton-cloud/terraform_modules_buffered_lambda.git"
  name                    = "component_one"
  subsystem               = var.subsystem
  qualifier               = var.qualifier
  revision                = var.revision

  image_repository_name   = aws_ecr_repository.common.name
  image_config = {
    command = ["your_component.component_one.process_event"]
  }
}

module "component_two" {
  source                  = "https://github.com/saxton-cloud/terraform_modules_buffered_lambda.git"
  name                    = "component_two"
  subsystem               = var.subsystem
  qualifier               = var.qualifier
  revision                = var.revision

  image_repository_name   = aws_ecr_repository.common.name
  image_config = {
    command = ["your_component.component_two.process_event"]
  }
}

```
