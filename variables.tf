variable "project_id" {
  type        = string
  description = "The GCP project ID that hosts the Artifact Registry."
}

# The default location used for the Artifact Registry repositories.
variable "default_location" {
  type        = string
  description = "The default location for the Artifact Registry repositories."
  default     = "europe-west1"
}

# Artifact Registry repositories.
variable "repositories" {
  type = map(object({
    description            = string
    format                 = optional(string, "DOCKER")
    mode                   = optional(string, "STANDARD_REPOSITORY")
    cleanup_policy_dry_run = optional(bool, true)
    docker_immutable_tags  = optional(bool, true)
    virtual_repository_config = optional(map(object({
      repository = string
      priority   = optional(number, 0)
    })), null)
    remote_repository_config_docker = optional(object({
      description                                           = optional(string, "")
      custom_repository_uri                                 = string
      disable_upstream_validation                           = optional(bool, false)
      username_password_credentials_username                = optional(string, "")
      username_password_credentials_password_secret_version = optional(string, "")
    }), null)
    readers  = optional(list(string), [])
    writers  = optional(list(string), [])
    location = optional(string, "")
  }))
  description = "List of Artifact Registry repositories to create."
}

variable "artifact_registry_listers_custom_role_name" {
  type        = string
  description = "Name of the custom role for Artifact Registry listers."
  default     = "custom.artifactRegistryLister"
}

variable "artifact_registry_listers" {
  type        = list(string)
  description = "List of principals that can list Artifact Registry repositories."
  default     = []
}
