variable "artifact_repositories" {
}

variable "project_id" {
}

module "repositories" {
  source       = "../"
  version      = "~>0.1"
  project_id   = var.project_id
  repositories = var.artifact_repositories
  artifact_registry_listers = [
    "domain:example.comn"
  ]
}
