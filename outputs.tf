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

output "artifact_registry_service_agent_member" {
  value       = local.artifact_registry_service_agent_member
  description = "The IAM member of the Artifact Registry service agent of this project. The owner of an upstream Artifact Registry repository must grant this member `roles/artifactregistry.serviceAgent` on that repository before a remote repository defined here can fill its cache from it. Null unless at least one repository sets `remote_repository_config_common`."
}

output "custom_role_artifact_registry_lister_id" {
  value       = length(var.artifact_registry_listers) > 0 ? local.custom_role_artifact_registry_lister_id : null
  description = "The ID of the custom role for Artifact Registry listers. The role is created only if the list of Artifact Registry listers is not empty."
}
