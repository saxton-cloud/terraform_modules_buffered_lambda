variable "qualifier" {
  description = "value used to distinguish one instance of the component from another within one or more accounts ( 'environment', branch, etc )"
  type        = string
}

variable "product_code" {
  description = "value used to group components and subsystems into a singe solution"
  type        = string
  default     = "acme"
}

variable "subsystem" {
  description = "value used to group components into subsystems of the solution"
  type        = string
}

variable "name" {
  description = "name of the lambda / component"
  type        = string
}

variable "description" {
  description = "describes the purpose/responsibilities of the lambda"
  type        = string
  default     = null
}

variable "revision" {
  description = "version of the component ( e.g. commit hash, build id, semver, etc)"
  type        = string
}

variable "kms_key_id" {
  description = "kms key id or alias to use for encryption - will create and use dedicated key not specified"
  type        = string
  default     = null
}

variable "environment" {
  description = "a map of environment variables to configure"
  type        = map(any)
  default = {
  }
}

variable "maximum_concurrency" {
  description = "maximum number of concurrent lambda instances servicing the input buffer"
  type        = number
  default     = 100
}

variable "memory_size" {
  description = "amount of memory allocated to each lambda instance"
  type        = number
  default     = 128
}

variable "image_repository_name" {
  description = "optional name of the respository to use when referencing the image (used when sharing an image between ecs tasks, lambda, etc )"
  type        = string
  default     = null
}

variable "timeout" {
  description = "amount of time your Lambda Function has to run in seconds"
  type        = number
  default     = 30
}

variable "image_config" {
  description = "optional image configuration overrides"
  type = object({
    command           = string
    entry_point       = string
    working_directory = string
  })
  default = null
}

variable "vpc_config" {
  description = "configuration required when hosting lambda within a vpc"
  type = object({
    subnet_ids         = list(string)
    security_group_ids = list(string)
  })
  default = null
}

variable "batch_size" {
  description = "number of messages from the input buffer to pull off at a time"
  type        = number
  default     = 10
}

variable "checkpoint_support" {
  description = "whether or not to support batch item failure reporting"
  type        = bool
  default     = false
}
