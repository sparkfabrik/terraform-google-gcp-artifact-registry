output "repositories" {
  value       = google_artifact_registry_repository.repositories
  description = "The created Artifact Repository repositories."
}

output "custom_role_artifact_registry_lister_id" {
  value       = length(var.artifact_registry_listers) > 0 ? local.custom_role_artifact_registry_lister_id : null
  description = "The ID of the custom role for Artifact Registry listers. The role is created only if the list of Artifact Registry listers is not empty."
}
