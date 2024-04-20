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

variable "kms_key" {
  description = "kms key ( resource or data ) used to encrypt"
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

variable "policy" {
  description = "specify any custom permissions your lambda requires here in the form of a serialised policy statement"
  type        = string
  default     = null
}

variable "assume_role_policy" {
  description = "specify any custom assume role permissions here"
  type        = string
  default     = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": ["sts:AssumeRole"]
    }
  ]
}
EOF
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
    command           = list(string)
    entry_point       = optional(list(string))
    working_directory = optional(string)
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
