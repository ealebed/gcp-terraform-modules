variable "location" {
  description = "Google Cloud region for non-global resource tag bindings; omit for global bindings"
  type        = string
  default     = null
}

variable "parent" {
  description = "Full Cloud Resource Manager resource name the tag is bound to (for example, //cloudresourcemanager.googleapis.com/folders/123456789)"
  type        = string

  validation {
    condition     = can(regex("^//cloudresourcemanager\\.googleapis\\.com/", var.parent))
    error_message = "parent must be a full Cloud Resource Manager resource name starting with //cloudresourcemanager.googleapis.com/."
  }
}

variable "tag_value" {
  description = "Tag to assign in PARENT:KEY_SHORT_NAME:VALUE_SHORT_NAME format (for example, organizations/123456789:environment:production)"
  type        = string

  validation {
    condition     = length(split(":", var.tag_value)) == 3
    error_message = "tag_value must be PARENT:KEY_SHORT_NAME:VALUE_SHORT_NAME."
  }

  validation {
    condition = alltrue([
      for part in split(":", var.tag_value) : length(trimspace(part)) > 0
    ])
    error_message = "tag_value parts must not be empty."
  }
}
