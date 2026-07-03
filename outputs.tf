output "binding_name" {
  description = "Name of the created tag binding"
  value       = var.location == null ? google_tags_tag_binding.tag_binding[0].name : google_tags_location_tag_binding.location_tag_binding[0].name
}

output "tag_value_id" {
  description = "ID of the resolved tag value"
  value       = data.google_tags_tag_value.tag_value.id
}
