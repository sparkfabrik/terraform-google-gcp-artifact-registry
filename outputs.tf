output "repositories" {
  value       = google_artifact_registry_repository.repositories
  description = "The created Artifact Repository repositories."
}

output "repositories_data" {
  value = {
    for repository_name, config in var.repositories : repository_name => {
      registry   = "${google_artifact_registry_repository.repositories[repository_name].location}-docker.pkg.dev",
      repository = "${google_artifact_registry_repository.repositories[repository_name].project}/${repository_name}",
    }
  }
  description = "The calculated data for the Artifact Registry repositories (registry and repository)."
}

output "custom_role_artifact_registry_lister_id" {
  value       = length(var.artifact_registry_listers) > 0 ? local.custom_role_artifact_registry_lister_id : null
  description = "The ID of the custom role for Artifact Registry listers. The role is created only if the list of Artifact Registry listers is not empty."
}

output "repositories_configurations" {
  value = local.repositories_final
  description = "The final configuration of the Artifact Registry repositories after merging with defaults."
}