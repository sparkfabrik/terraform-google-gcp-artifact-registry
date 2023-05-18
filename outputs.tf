output "repositories" {
  value       = google_artifact_registry_repository.repositories
  description = "The created Artifact Repository repositories."
}

output "custom_role_artifact_registry_lister_id" {
  value       = local.custom_role_artifact_registry_lister_id
  description = "The ID of the custom role for Artifact Registry listers."
}
