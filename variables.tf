variable "capabilities" {
  description = "The capabilities required to deploy the cloudformation template"
  type        = list(string)
  default     = ["CAPABILITY_NAMED_IAM", "CAPABILITY_AUTO_EXPAND", "CAPABILITY_IAM"]
}

variable "call_as" {
  description = "Specifies whether you are acting as an account administrator in the organization's management account or as a delegated administrator in a member account"
  type        = string
  default     = "SELF"
}

variable "permission_model" {
  description = "Describes how the IAM roles required for your StackSet are created"
  type        = string
  default     = "SERVICE_MANAGED"

  validation {
    condition     = contains(["SELF_MANAGED", "SERVICE_MANAGED"], var.permission_model)
    error_message = "permission_model must be either SELF or SERVICE_MANAGED"
  }
}

variable "enabled_regions" {
  description = "The regions to deploy the cloudformation stack to (if empty, deploys to current region)"
  type        = list(string)
  default     = null
}

variable "accounts" {
  description = "When using an account deployments, the following accounts will be included"
  type        = list(string)
  default     = []
}

variable "exclude_accounts" {
  description = "When using an organizational deployments, the following accounts will be excluded"
  type        = list(string)
  default     = null
}

variable "description" {
  description = "The description of the cloudformation stack"
  type        = string
}

variable "max_concurrent_count" {
  description = "The maximum number of concurrent deployments"
  type        = number
  default     = 10
}

variable "failure_tolerance_count" {
  description = "The number of failures that are tolerated before the stack operation is stopped"
  type        = number
  default     = 0
}

variable "retain_stacks_on_account_removal" {
  description = "Whether to retain stacks on account removal"
  type        = bool
  default     = true
}

variable "name" {
  description = "The name of the cloudformation stack"
  type        = string
}

variable "parameters" {
  description = "The parameters to pass to the cloudformation template"
  type        = map(string)
  default     = {}
}

variable "region" {
  description = "The region to deploy the cloudformation template"
  type        = string
  default     = null
}

variable "organizational_units" {
  description = "The organizational units to deploy the stackset to"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "The tags to apply to the cloudformation stack"
  type        = map(string)
}

variable "template" {
  description = "The body of the cloudformation template to deploy"
  type        = string
}

