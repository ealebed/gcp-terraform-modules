resource "google_folder" "folder" {
  display_name        = var.display_name
  parent              = var.parent
  deletion_protection = var.deletion_protection
}

module "org_policy" {
  source   = "terraform-google-modules/org-policy/google//modules/org_policy_v2"
  version  = "~> 7.2"
  for_each = local.org_policies

  policy_root    = "folder"
  policy_root_id = google_folder.folder.folder_id
  constraint     = each.value.constraint
  policy_type    = each.value.type

  rules = [
    {
      enforcement = each.value.enforced
      allow       = each.value.allowed
      deny        = each.value.denied
      conditions  = []
    }
  ]
}

module "tag_assignment" {
  source   = "git::https://github.com/ealebed/gcp-terraform-modules.git?ref=google-tag-assignment/v1.0.0"
  for_each = toset(var.assigned_tags)

  parent    = "//cloudresourcemanager.googleapis.com/${google_folder.folder.name}"
  tag_value = each.value
}
