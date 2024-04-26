# Terraform GCP Artifact Registry

![tflint status](https://github.com/sparkfabrik/terraform-sparkfabrik-gcp-http-monitoring/actions/workflows/tflint.yml/badge.svg?branch=main)

This module enable Artifact Registry api in the GCP (Google Cloud Platform) project, create repositories and assign read and write IAM permissions.

You MUST configure the required "google" provider inside your root module.

This module is provided without any kind of warranty and is GPL3 licensed.

<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 5.26.0 |

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 5.26.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_artifact_registry_listers"></a> [artifact\_registry\_listers](#input\_artifact\_registry\_listers) | List of principals that can list Artifact Registry repositories. | `list(string)` | `[]` | no |
| <a name="input_artifact_registry_listers_custom_role_name"></a> [artifact\_registry\_listers\_custom\_role\_name](#input\_artifact\_registry\_listers\_custom\_role\_name) | Name of the custom role for Artifact Registry listers. | `string` | `"custom.artifactRegistryLister"` | no |
| <a name="input_default_location"></a> [default\_location](#input\_default\_location) | The default location for the Artifact Registry repositories. | `string` | `"europe-west1"` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The GCP project ID that hosts the Artifact Registry. | `string` | n/a | yes |
| <a name="input_repositories"></a> [repositories](#input\_repositories) | List of Artifact Registry repositories to create. | <pre>map(object({<br>    description            = string<br>    format                 = optional(string, "DOCKER")<br>    mode                   = optional(string, "STANDARD_REPOSITORY")<br>    cleanup_policy_dry_run = optional(bool, true)<br>    docker_immutable_tags  = optional(bool, true)<br>    virtual_repository_config = optional(map(object({<br>      repository = string<br>      priority   = optional(number, 0)<br>    })), null)<br>    remote_repository_config_docker = optional(object({<br>      description                                           = optional(string, "")<br>      custom_repository_uri                                 = string<br>      username_password_credentials_username                = optional(string, "")<br>      username_password_credentials_password_secret_version = optional(string, "")<br>    }), null)<br>    readers  = optional(list(string), [])<br>    writers  = optional(list(string), [])<br>    location = optional(string, "")<br>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_custom_role_artifact_registry_lister_id"></a> [custom\_role\_artifact\_registry\_lister\_id](#output\_custom\_role\_artifact\_registry\_lister\_id) | The ID of the custom role for Artifact Registry listers. |
| <a name="output_repositories"></a> [repositories](#output\_repositories) | The created Artifact Repository repositories. |

## Resources

| Name | Type |
|------|------|
| [google_artifact_registry_repository.repositories](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/artifact_registry_repository) | resource |
| [google_artifact_registry_repository_iam_member.member](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/artifact_registry_repository_iam_member) | resource |
| [google_project_iam_binding.artifact_registry_lister](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_binding) | resource |
| [google_project_iam_custom_role.artifact_registry_lister](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_custom_role) | resource |
| [google_project_service.project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |

## Modules

No modules.


<!-- END_TF_DOCS -->
