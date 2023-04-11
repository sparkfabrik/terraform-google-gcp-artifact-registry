variable "project_id" {
  type        = string
  description = "The project name to deploy the resources."
}

# Artifact Registry repositories.
variable "repositories" {
  type = map(object({
    description = string
    format      = optional(string, "DOCKER")
    readers     = optional(list(string), [])
    writers     = optional(list(string), [])
    location    = string
  }))
  description = "List of Artifact Registry repositories to create."
}
