# Tasks

## 1. Artifact Registry upstream configuration

- [ ] 1.1 Add `remote_repository_config_common = optional(object({ description = optional(string, ""), uri = string, disable_upstream_validation = optional(bool, false) }), null)` to the `repositories` object type in `variables.tf`, documenting in the variable description that `uri` accepts an Artifact Registry resource path, an Artifact Registry repository URL or a registry URI, and that an Artifact Registry upstream must be a standard-mode repository.
- [ ] 1.2 Replace the current `REMOTE_REPOSITORY` validation with the exactly-one rule over `remote_repository_config_docker` and `remote_repository_config_common`, with an error message naming both fields.
- [ ] 1.3 Add the `dynamic "remote_repository_config"` block rendering `common_repository`, with the same empty-description fallback to the repository description as the docker block.
- [ ] 1.4 Guard the existing docker `remote_repository_config` block on `remote_repository_config_docker != null`, so the two blocks are mutually exclusive at render time.
- [ ] 1.5 Make `local.remote_repositories` and `data.google_secret_manager_secret_version.remote_repository_secrets` tolerate a null docker configuration: the `lookup(repository.remote_repository_config_docker, ...)` calls in `main.tf:118-126` run for every `REMOTE_REPOSITORY` repository.
- [ ] 1.6 Document the cross-project prerequisites in the variable description and `README.md`: the upstream owner grants `roles/artifactregistry.serviceAgent` to the consumer project's service agent before the remote repository is created, the upstream must be standard mode, and `disable_upstream_validation` is the escape hatch when the grant is not yet in place.

## 2. Service agent grant

- [ ] 2.1 Add `service_agents = optional(list(string), [])` to the `repositories` object type in `variables.tf`, documenting that `roles/artifactregistry.serviceAgent` includes `artifactregistry.versions.delete` and belongs at repository scope only.
- [ ] 2.2 Extend `local.member_and_role_per_repo` with a third branch mapping `service_agents` to `roles/artifactregistry.serviceAgent`, keeping the existing `"<repository>--<role>--<member>"` key shape.
- [ ] 2.3 Verify no state address changes for existing `readers` and `writers` bindings: a plan against the example must show only additions.

## 3. Service agent member output

- [ ] 3.1 Add a `google_project` data source gated on at least one repository using `remote_repository_config_common`.
- [ ] 3.2 Add an output returning `serviceAccount:service-<project_number>@gcp-sa-artifactregistry.iam.gserviceaccount.com`, `null` when the data source is not created, with a description stating that this is the member an upstream repository owner must grant `roles/artifactregistry.serviceAgent` to.

## 4. Example, docs, changelog

- [ ] 4.1 Add to `examples/test.tfvars` a `REMOTE_REPOSITORY` repository using `remote_repository_config_common` with an Artifact Registry resource path upstream, and a standard repository carrying a `service_agents` entry.
- [ ] 4.2 Update `examples/README.md` to describe the two new sample repositories.
- [ ] 4.3 Regenerate the terraform-docs block in `README.md` (`make generate-docs`).
- [ ] 4.4 Add a `CHANGELOG.md` entry under `## [Unreleased]` / `### Added`, one bullet per feature, noting that a consumer which declares its own copy of the `repositories` object type must mirror the new fields before it can use them.

## 5. Tests

- [ ] 5.1 `make lint` passes with the extended example.
- [ ] 5.2 `make tfsec` passes with the extended example.
- [ ] 5.3 Add `tests/remote_repository.tftest.hcl` with `mock_provider "google"` and `command = plan` runs asserting the `common_repository` rendering, the unchanged docker rendering including the `DOCKER_HUB` branch, and both validation failures via `expect_failures`.
- [ ] 5.4 Add a `terraform test` job to `.github/workflows/`, pinning a Terraform version >= 1.7, without changing the module's `required_version`.

## 6. Release

- [ ] 6.1 Release `0.16.0` after review.
- [ ] 6.2 Verify the implementation against this change (`openspec validate`) and archive it.
