# buffered_lambda

> lambda with input and dead-letter queues

## general configuration

- **name** - _str_ - name of the component
- **qualifier** - _str_ - value used to distinguish one instance of this component from another in one or more aws accounts ( e.g. 'environment', branch, user, etc )
- **revision** - _str_ - version of the component ( e.g. commit hash, build id, semver, etc)
- **kms_key_id** - _str_ - id or alias of kms key to use for encryption - if not supplied, a dedicated kms key and alias will be created and used
- **maximum_concurrency** - _number_ - maximum number of concurrent lambda instances servicing the input buffer ( defaults to 100 )
- **memory_size** - _number_ - amount of memory allocated to each lambda instance ( defaults to 128 )

```hcl
module "your_component" {
  source    = "https://github.com/acme-widgets-org/terraform_modules_buffered_lambda.git"
  name      = "your_component"
  subsystem = "your_subsystem"
  qualifier = "dev"
  revision  = "7a51792" # or semver or commit datetime
}
```
