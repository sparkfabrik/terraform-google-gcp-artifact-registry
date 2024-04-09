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
    description = string
    format      = optional(string, "DOCKER")
    mode        = optional(string, "STANDARD_REPOSITORY")
    virtual_repository_config = optional(map(object({
      repository = string
      priority   = optional(number, 0)
    })), null)
    remote_repository_config_docker = optional(object({
      description                                           = string
      public_repository                                     = string
      username_password_credentials_username                = optional(string, "")
      username_password_credentials_password_secret_version = optional(string, "")
    }), null)
    remote_repository_config = optional(map(any), null)
    readers                  = optional(list(string), [])
    writers                  = optional(list(string), [])
    location                 = optional(string, "")
  }))
  description = "List of Artifact Registry repositories to create."

  # validation {
  #   condition     = contains(["STANDARD_REPOSITORY", "VIRTUAL_REPOSITORY", "REMOTE_REPOSITORY"], var.repositories[each.key].mode)
  #   error_message = "Mode must be one of 'STANDARD_REPOSITORY', 'VIRTUAL_REPOSITORY', or 'REMOTE_REPOSITORY'."
  # }

  # validation {
  #   condition     = var.repositories[each.key].mode == "VIRTUAL_REPOSITORY" && var.repositories[each.key].virtual_repository_config != null
  #   error_message = "value of 'virtual_repository_config' must be set for 'VIRTUAL_REPOSITORY' mode."
  # }

  # validation {
  #   condition     = var.repositories[each.key].mode == "REMOTE_REPOSITORY" && var.repositories[each.key].remote_repository_config != null
  #   error_message = "value of 'remote_repository_config' must be set for 'REMOTE_REPOSITORY' mode."
  # }
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
