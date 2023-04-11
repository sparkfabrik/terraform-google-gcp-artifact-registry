# Terraform GCP Artifact Registry

![tflint status](https://github.com/sparkfabrik/terraform-sparkfabrik-gcp-http-monitoring/actions/workflows/tflint.yml/badge.svg?branch=main)

This module enable Artifact Registry api in the GCP (Google Cloud Platform) project, create repositories and assign read and write IAM permissions.

You MUST configure the required "google" provider inside your root module.

This module is provided without any kind of warranty and is GPL3 licensed.

<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 3.0 |
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 3.0 |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The project name to deploy the resources. | `string` | n/a | yes |
| <a name="input_repositories"></a> [repositories](#input\_repositories) | List of Artifact Registry repositories to create. | <pre>map(object({<br>    description = string<br>    format      = optional(string, "DOCKER")<br>    readers     = optional(list(string), [])<br>    writers     = optional(list(string), [])<br>    location    = string<br>  }))</pre> | n/a | yes |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_repositories"></a> [repositories](#output\_repositories) | The created Artifact Repository repositories. |
## Resources

| Name | Type |
|------|------|
| [google_artifact_registry_repository.repositories](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/artifact_registry_repository) | resource |
| [google_artifact_registry_repository_iam_member.member](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/artifact_registry_repository_iam_member) | resource |
| [google_project_service.project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
## Modules

No modules.

<!-- END_TF_DOCS -->
