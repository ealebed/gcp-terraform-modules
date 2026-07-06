output "folder_id" {
  description = "Numeric ID of the Google Cloud folder"
  value       = google_folder.folder.folder_id
}

output "id" {
  description = "Numeric ID of the Google Cloud folder"
  value       = google_folder.folder.folder_id
}

output "name" {
  description = "Resource name of the Google Cloud folder (folders/FOLDER_ID)"
  value       = google_folder.folder.name
}
