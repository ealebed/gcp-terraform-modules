data "google_tags_tag_key" "tag_key" {
  parent     = local.tag_value_parts[0]
  short_name = local.tag_value_parts[1]
}

data "google_tags_tag_value" "tag_value" {
  parent     = data.google_tags_tag_key.tag_key.id
  short_name = local.tag_value_parts[2]
}

resource "google_tags_tag_binding" "tag_binding" {
  count = var.location == null ? 1 : 0

  parent    = var.parent
  tag_value = data.google_tags_tag_value.tag_value.id
}

resource "google_tags_location_tag_binding" "location_tag_binding" {
  count = var.location != null ? 1 : 0

  parent    = var.parent
  tag_value = data.google_tags_tag_value.tag_value.id
  location  = var.location
}
