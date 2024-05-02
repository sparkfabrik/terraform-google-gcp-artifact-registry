
module "repositories" {
  source       = "../"
  version      = "~>0.3"
  project_id   = var.project_id
  repositories = var.repositories
  artifact_registry_listers = [
    "domain:example.comn"
  ]
}
