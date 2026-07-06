variable "assigned_tags" {
  description = "Tags to assign in PARENT:KEY_SHORT_NAME:VALUE_SHORT_NAME format (for example, organizations/123456789:environment:production)"
  type        = list(string)
  default     = []
}

variable "deletion_protection" {
  description = "Whether Terraform will be prevented from destroying the folder"
  type        = bool
  default     = true
}

variable "display_name" {
  description = "Display name of the Google Cloud folder"
  type        = string

  validation {
    condition     = length(trimspace(var.display_name)) > 0
    error_message = "display_name must not be empty."
  }
}

variable "org_policies" {
  description = "Organization policies to apply at the folder level"
  type = list(object({
    type       = string
    constraint = string
    enforced   = optional(bool, false)
    allowed    = optional(list(string), [])
    denied     = optional(list(string), [])
  }))
  default = []

  validation {
    condition = alltrue([
      for policy in var.org_policies :
      contains(["boolean", "list"], policy.type)
    ])
    error_message = "org_policies.type must be boolean or list."
  }

  validation {
    condition = alltrue([
      for policy in var.org_policies :
      length(trimspace(policy.constraint)) > 0
    ])
    error_message = "org_policies.constraint must not be empty."
  }
}

variable "parent" {
  description = "Parent resource name (organizations/ORG_ID or folders/FOLDER_ID)"
  type        = string

  validation {
    condition     = can(regex("^(organizations|folders)/[0-9]+$", var.parent))
    error_message = "parent must be organizations/ORG_ID or folders/FOLDER_ID."
  }
}
