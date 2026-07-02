resource "google_storage_bucket" "bucket" {
  project                     = var.project
  name                        = var.bucket.name
  location                    = var.bucket.location
  storage_class               = var.bucket.storage_class
  labels                      = local.labels
  force_destroy               = var.bucket.force_destroy
  public_access_prevention    = var.bucket.public_access_prevention
  uniform_bucket_level_access = true

  dynamic "encryption" {
    for_each = var.bucket.encryption != null && var.bucket.encryption.default_kms_key_name != null ? [var.bucket.encryption] : []
    content {
      default_kms_key_name = encryption.value.default_kms_key_name
    }
  }

  dynamic "hierarchical_namespace" {
    for_each = var.bucket.hierarchical_namespace ? [1] : []
    content {
      enabled = true
    }
  }

  dynamic "versioning" {
    for_each = var.bucket.versioning ? [1] : []
    content {
      enabled = true
    }
  }

  dynamic "website" {
    for_each = var.bucket.website.enabled ? [1] : []
    content {
      main_page_suffix = var.bucket.website.main_page_suffix
      not_found_page   = var.bucket.website.not_found_page
    }
  }

  dynamic "logging" {
    for_each = var.bucket.logging != null ? [var.bucket.logging] : []
    content {
      log_bucket        = logging.value.log_bucket
      log_object_prefix = logging.value.log_object_prefix
    }
  }

  dynamic "retention_policy" {
    for_each = var.bucket.retention_policy != null ? [var.bucket.retention_policy] : []
    content {
      retention_period = retention_policy.value.retention_period
      is_locked        = retention_policy.value.is_locked
    }
  }

  dynamic "soft_delete_policy" {
    for_each = var.bucket.soft_delete_policy.retention_duration_seconds != null ? [var.bucket.soft_delete_policy] : []
    content {
      retention_duration_seconds = soft_delete_policy.value.retention_duration_seconds
    }
  }

  dynamic "autoclass" {
    for_each = var.bucket.autoclass.enabled || var.bucket.autoclass.terminal_storage_class != null ? [var.bucket.autoclass] : []
    content {
      enabled                = autoclass.value.enabled
      terminal_storage_class = autoclass.value.terminal_storage_class
    }
  }

  dynamic "lifecycle_rule" {
    for_each = var.bucket.lifecycle_rules
    content {
      action {
        type          = lifecycle_rule.value.action.type
        storage_class = lifecycle_rule.value.action.storage_class
      }
      condition {
        age                        = lifecycle_rule.value.condition.age
        send_age_if_zero           = lifecycle_rule.value.condition.send_age_if_zero
        created_before             = lifecycle_rule.value.condition.created_before
        with_state                 = coalesce(lifecycle_rule.value.condition.with_state, lifecycle_rule.value.condition.is_live != null ? (lifecycle_rule.value.condition.is_live ? "LIVE" : "ARCHIVED") : null)
        matches_storage_class      = lifecycle_rule.value.condition.matches_storage_class != null ? split(",", lifecycle_rule.value.condition.matches_storage_class) : null
        matches_prefix             = lifecycle_rule.value.condition.matches_prefix != null ? split(",", lifecycle_rule.value.condition.matches_prefix) : null
        matches_suffix             = lifecycle_rule.value.condition.matches_suffix != null ? split(",", lifecycle_rule.value.condition.matches_suffix) : null
        num_newer_versions         = lifecycle_rule.value.condition.num_newer_versions
        custom_time_before         = lifecycle_rule.value.condition.custom_time_before
        days_since_custom_time     = lifecycle_rule.value.condition.days_since_custom_time
        days_since_noncurrent_time = lifecycle_rule.value.condition.days_since_noncurrent_time
        noncurrent_time_before     = lifecycle_rule.value.condition.noncurrent_time_before
      }
    }
  }

  dynamic "cors" {
    for_each = var.bucket.cors
    content {
      origin          = cors.value.origin
      method          = cors.value.method
      response_header = cors.value.response_header
      max_age_seconds = cors.value.max_age_seconds
    }
  }
}

resource "google_storage_bucket_iam_member" "bucket_iam" {
  for_each = local.grouped_bindings

  bucket = google_storage_bucket.bucket.name
  role   = each.value.role
  member = each.value.member
}
