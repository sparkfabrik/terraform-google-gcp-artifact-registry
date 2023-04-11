module "repositories" {
  source  = "../"
  version = "~>0.1"
  project_id = var.project_id
  repositories = var.repositories
}