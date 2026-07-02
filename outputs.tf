output "name" {
  description = "Name of the Cloud Storage bucket"
  value       = google_storage_bucket.bucket.name
}

output "self_link" {
  description = "URI of the Cloud Storage bucket"
  value       = google_storage_bucket.bucket.self_link
}

output "url" {
  description = "Base URL of the Cloud Storage bucket"
  value       = google_storage_bucket.bucket.url
}

output "bucket" {
  description = "Resource attributes of the Cloud Storage bucket"
  value       = google_storage_bucket.bucket
}
