variable "project_id" {
  type        = string
  description = "The GCP project ID to host the cluster in"
}

# Artifact Registry repositories.
variable "artifact_repositories" {
  type = map(object({
    description = string
    format      = optional(string, "DOCKER")
    readers     = optional(list(string), [])
    writers     = optional(list(string), [])
    location    = string
  }))
  description = "List of Artifact Registry repositories to create."
}
