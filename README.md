# buffered_lambda

> lambda with input and dead-letter queues

## general configuration

- **name** - _str_ - name of the component
- **qualifier** - _str_ - value used to distinguish one instance of this component from another in one or more aws accounts ( e.g. 'environment', branch, user, etc )
- **revision** - _str_ - version of the component ( e.g. commit hash, build id, semver, etc)
- **kms_key_id** - _str_ - id or alias of kms key to use for encryption - if not supplied, a dedicated kms key and alias will be created and used
- **maximum_concurrency** - _number_ - maximum number of concurrent lambda instances servicing the input buffer ( defaults to 100 )
- **memory_size** - _number_ - amount of memory allocated ( MiB ) to each lambda instance ( defaults to 128 )
- **timeout** - _number_ - amount of time, in seconds, the lambda is permitted to execute ( defaults to 30 )

```hcl
module "your_component" {
  source      = "https://github.com/acme-widgets-org/terraform_modules_buffered_lambda.git"
  name        = var.name
  description = "some description of the purpose of your_component"
  subsystem   = var.subsystem
  qualifier   = var.qualifier
  revision    = var.revision

  memory_size = 512
  timeout     = 180
}
```

## input buffer configuration

- **batch_size** - _number_ - maximum number of items to ingest per invokation ( defaults to 10 )
- **checkpoint_support** - _bool_ - enables [AWS lambda checkpointing](https://docs.aws.amazon.com/lambda/latest/dg/with-ddb.html#services-ddb-batchfailurereporting) feature _( this affects the lambda's required response structure )_

## vpc hosting

to host your lambda within a vpc, you must provide the `vpc_config` block, specifying the relavant information

### vpc_config settings

- **subnet_ids** - _list(str)_ - list of subnet ids to host the lambda instances
- **security_group_ids** - _list(str)_ - security group ids to associate with the lambda

```hcl

module "your_component" {
  source      = "https://github.com/acme-widgets-org/terraform_modules_buffered_lambda.git"
  name        = var.name
  ...
  vpc_config = {
    subnet_ids = [<your_vpc_subnet_ids_here>]
    security_group_ids = [<your_security_group_ids_here>]
  }
}
```

## environment variable configuration

environment variables make be specified using the `environment` attribute

```hcl
module "your_component" {
  source      = "https://github.com/acme-widgets-org/terraform_modules_buffered_lambda.git"
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
  source                  = "https://github.com/acme-widgets-org/terraform_modules_buffered_lambda.git"
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
  source                  = "https://github.com/acme-widgets-org/terraform_modules_buffered_lambda.git"
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
