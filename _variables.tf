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
