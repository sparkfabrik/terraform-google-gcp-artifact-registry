variable "repositories" {
  description = "List of Artifact Registry repositories to create."
  type        = map(any)
}

variable "project_id" {
  description = "The GCP project ID that hosts the Artifact Registry."
  type        = string
}
