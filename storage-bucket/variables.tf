variable "bucket" {
  description = "Cloud Storage bucket configuration"
  type = object({
    name                     = string
    location                 = string
    labels                   = optional(map(string), {})
    force_destroy            = optional(bool, false)
    iam_bindings             = optional(map(list(string)), {})
    public_access_prevention = optional(string, "enforced")
    storage_class            = optional(string)
    versioning               = optional(bool, false)
    hierarchical_namespace   = optional(bool, false)
    autoclass = optional(object({
      enabled                = optional(bool, false)
      terminal_storage_class = optional(string)
    }), {})
    cors = optional(list(object({
      origin          = optional(list(string))
      method          = optional(list(string))
      response_header = optional(list(string))
      max_age_seconds = optional(number)
    })), [])
    encryption = optional(object({
      default_kms_key_name = optional(string)
    }))
    lifecycle_rules = optional(list(object({
      action = object({
        type          = string
        storage_class = optional(string)
      })
      condition = object({
        age                        = optional(number)
        send_age_if_zero           = optional(bool)
        created_before             = optional(string)
        with_state                 = optional(string)
        is_live                    = optional(bool)
        matches_storage_class      = optional(string)
        matches_prefix             = optional(string)
        matches_suffix             = optional(string)
        num_newer_versions         = optional(number)
        custom_time_before         = optional(string)
        days_since_custom_time     = optional(number)
        days_since_noncurrent_time = optional(number)
        noncurrent_time_before     = optional(string)
      })
    })), [])
    logging = optional(object({
      log_bucket        = string
      log_object_prefix = optional(string)
    }))
    retention_policy = optional(object({
      retention_period = number
      is_locked        = optional(bool, false)
    }))
    soft_delete_policy = optional(object({
      retention_duration_seconds = optional(number)
    }), {})
    website = optional(object({
      enabled          = optional(bool, false)
      main_page_suffix = optional(string, "index.html")
      not_found_page   = optional(string, "index.html")
    }), {})
  })

  validation {
    condition     = length(var.bucket.name) >= 3 && length(var.bucket.name) <= 63
    error_message = "Bucket name must be between 3 and 63 characters."
  }

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9._-]*[a-z0-9]$", var.bucket.name))
    error_message = "Bucket name must contain only lowercase letters, numbers, dashes, underscores, and dots, and must start and end with a letter or number."
  }

  validation {
    condition     = contains(["enforced", "inherited"], var.bucket.public_access_prevention)
    error_message = "public_access_prevention must be enforced or inherited."
  }

  validation {
    condition = (
      var.bucket.storage_class == null ||
      contains(["STANDARD", "NEARLINE", "COLDLINE", "ARCHIVE"], var.bucket.storage_class)
    )
    error_message = "storage_class must be STANDARD, NEARLINE, COLDLINE, or ARCHIVE."
  }
}

variable "iam_bindings" {
  description = "IAM bindings applied to the bucket in addition to bucket.iam_bindings"
  type        = map(list(string))
  default     = {}
}

variable "labels" {
  description = "Labels applied to the bucket; bucket.labels take precedence"
  type        = map(string)
  default     = {}
}

variable "project" {
  description = "Google Cloud project ID"
  type        = string
}
