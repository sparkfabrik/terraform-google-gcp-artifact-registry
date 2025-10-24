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

# Artifact Registry repositories.
variable "repositories" {
  type = map(object({
    description                     = string
    format                          = optional(string, "DOCKER")
    mode                            = optional(string, "STANDARD_REPOSITORY")
    cleanup_policy_dry_run          = optional(bool, true)
    enable_default_cleanup_policies = optional(bool, null)
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
    readers  = optional(list(string), [])
    writers  = optional(list(string), [])
    location = optional(string, "")
    labels   = optional(map(string), {})
  }))

  description = "List of Artifact Registry repositories to create."

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
    condition     = alltrue([for repo in var.repositories : repo.mode == "REMOTE_REPOSITORY" ? lookup(repo, "remote_repository_config_docker", null) != null : true])
    error_message = "Remote repository configuration is required for the REMOTE_REPOSITORY mode."
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

variable "default_cleanup_policies" {
  type = map(object({
    action = string
    condition = optional(object({
      tag_state             = optional(string)
      tag_prefixes          = optional(list(string), [])
      version_name_prefixes = optional(list(string), [])
      package_name_prefixes = optional(list(string), [])
      older_than            = optional(string)
      newer_than            = optional(string)
    }), {})
    most_recent_versions = optional(object({
      package_name_prefixes = optional(list(string), [])
      keep_count            = optional(number, null)
    }), {})
  }))
  description = "Default cleanup policies to apply to repositories. Used when repository's enable_default_cleanup_policies is true (default). Repository-specific cleanup_policies are merged with these defaults."
  default = {
    # Keep tagged images: keep the last 5 versions
    keep-tagged-images = {
      action = "KEEP"
      most_recent_versions = {
        keep_count = 5
      }
    }
    # Keep protected tags always (latest, main, master, develop, stage, semantic versions with v prefix)
    keep-protected-tags = {
      action = "KEEP"
      condition = {
        tag_state    = "TAGGED"
        tag_prefixes = ["latest", "main", "master", "develop", "stage", "v1", "v2", "v3", "v4", "v5", "v6", "v7", "v8", "v9"]
      }
    }
    # Keep semantic versions without prefix (1.0, 1.0.0, 1-0-0, etc.)
    # NOTE: GCP Artifact Registry does not support wildcard version prefixes.
    #       The version_name_prefixes below explicitly match tags that start with a single digit (0–9)
    #       followed by '.' or '-' (e.g: 1.0, 2-0-0). Tags with major version >= 10 (e.g: 10.0) will NOT be matched.
    keep-semantic-versions = {
      action = "KEEP"
      condition = {
        tag_state             = "TAGGED"
        version_name_prefixes = ["0.", "1.", "2.", "3.", "4.", "5.", "6.", "7.", "8.", "9.", "0-", "1-", "2-", "3-", "4-", "5-", "6-", "7-", "8-", "9-"]
      }
    }
    # Delete everything else older than 90 days
    remove-old-images = {
      action = "DELETE"
      condition = {
        tag_state  = "ANY"
        older_than = "7776000s" # 90 days
      }
    }
  }
}
