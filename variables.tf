variable "project_id" {
  type        = string
  description = "The GCP project ID that hosts the Artifact Registry."
}

variable "enable_api" {
  type        = bool
  description = "Enable the Artifact Registry API."
  default     = true
}

# The default location used for the Artifact Registry repositories.
variable "default_location" {
  type        = string
  description = "The default location for the Artifact Registry repositories."
  default     = "europe-west1"
}

# Retention threshold for the default "remove-old-images" cleanup policy.
variable "remove_old_images_older_than" {
  type        = string
  description = "The `older_than` threshold, expressed as a duration in seconds (e.g. \"2592000s\" for 30 days), for the default \"remove-old-images\" cleanup policy. Images older than this that are not retained by a KEEP policy are deleted. Only applies to repositories with `cleanup_policies_enable_default = true`. Set to \"7776000s\" to keep the previous 90 days behavior."
  default     = "2592000s" # 30 days

  validation {
    condition     = can(regex("^[0-9]+s$", var.remove_old_images_older_than))
    error_message = "The remove_old_images_older_than value must be a duration in seconds ending with \"s\" (e.g. \"2592000s\")."
  }
}

# Artifact Registry repositories.
variable "repositories" {
  type = map(object({
    description                     = string
    format                          = optional(string, "DOCKER")
    mode                            = optional(string, "STANDARD_REPOSITORY")
    vulnerability_scanning_enabled  = optional(bool, false)
    cleanup_policy_dry_run          = optional(bool, false)
    cleanup_policies_enable_default = optional(bool, true)
    cleanup_policies = optional(map(object({
      action = optional(string, ""),
      condition = optional(object({
        tag_state             = optional(string),
        tag_prefixes          = optional(list(string), []),
        version_name_prefixes = optional(list(string), []),
        package_name_prefixes = optional(list(string), []),
        older_than            = optional(string),
        newer_than            = optional(string),
      }), {}),
      most_recent_versions = optional(object({
        package_name_prefixes = optional(list(string), []),
        keep_count            = optional(number, null)
      }), {})
    })), {})
    docker_immutable_tags = optional(bool, false)
    virtual_repository_config = optional(map(object({
      repository = string
      priority   = optional(number, 0)
    })), null)
    remote_repository_config_docker = optional(object({
      description                                           = optional(string, "")
      custom_repository_uri                                 = string
      disable_upstream_validation                           = optional(bool, false)
      username_password_credentials_username                = optional(string, "")
      username_password_credentials_password_secret_name    = optional(string, "")
      username_password_credentials_password_secret_version = optional(string, "")
    }), null)
    remote_repository_config_common = optional(object({
      description                 = optional(string, "")
      uri                         = string
      disable_upstream_validation = optional(bool, false)
    }), null)
    readers  = optional(list(string), [])
    writers  = optional(list(string), [])
    location = optional(string, "")
    labels   = optional(map(string), {})
  }))

  description = "List of Artifact Registry repositories to create. A repository in `REMOTE_REPOSITORY` mode must set exactly one of `remote_repository_config_docker` (an external Docker registry, credentials read from Secret Manager) and `remote_repository_config_common` (another Artifact Registry repository, no stored credentials). An Artifact Registry upstream must be a standard-mode repository, and one in another project requires a `roles/artifactregistry.serviceAgent` grant on it before the remote repository is created. See the \"Remote repositories\" section of the README for the full prerequisites."

  validation {
    condition     = alltrue([for policy in flatten([for repo in var.repositories : [for cp in repo.cleanup_policies : cp]]) : contains(["DELETE", "KEEP"], policy.action)])
    error_message = "Cleanup policy action must be either DELETE or KEEP."
  }

  validation {
    condition     = alltrue([for policy in flatten([for repo in var.repositories : [for cp in repo.cleanup_policies : cp]]) : policy.condition.tag_state == null || contains(["ANY", "TAGGED", "UNTAGGED"], (policy.condition.tag_state == null ? "" : policy.condition.tag_state))])
    error_message = "Tag state must be ANY, TAGGED, or UNTAGGED."
  }

  validation {
    condition = alltrue([
      for policy in flatten([for repo in var.repositories : [for cp in repo.cleanup_policies : cp]]) :
      policy.most_recent_versions == {} || try((policy.most_recent_versions.keep_count == null || policy.most_recent_versions.keep_count > 0), true)
    ])
    error_message = "Keep count must be null or greater than zero if specified."
  }

  validation {
    condition = alltrue([
      for repo in var.repositories : repo.mode != "REMOTE_REPOSITORY" ? true : (
        (repo.remote_repository_config_docker != null ? 1 : 0) +
        (repo.remote_repository_config_common != null ? 1 : 0)
      ) == 1
    ])
    error_message = "A repository in REMOTE_REPOSITORY mode must set exactly one of remote_repository_config_docker or remote_repository_config_common."
  }
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

variable "default_labels" {
  type        = map(string)
  description = "Default labels to apply to all Artifact Registry resources."
  default = {
    "managed-by" = "terraform"
  }
}

variable "additional_labels" {
  type        = map(string)
  description = "Additional labels to apply to all Artifact Registry resources. This variable will be merged with the default_labels variable and the labels defined in the repositories variable."
  default     = {}
}
