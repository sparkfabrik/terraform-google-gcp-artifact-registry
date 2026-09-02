# Tasks

## 1. Artifact Registry upstream configuration

- [x] 1.1 Add `remote_repository_config_common = optional(object({ description = optional(string, ""), uri = string, disable_upstream_validation = optional(bool, false) }), null)` to the `repositories` object type in `variables.tf`, with a variable description stating the exactly-one rule, the two remote configurations and the standard-mode upstream requirement, and pointing at the README section for the accepted `uri` shapes and the full prerequisites.
- [x] 1.2 Replace the current `REMOTE_REPOSITORY` validation with the exactly-one rule over `remote_repository_config_docker` and `remote_repository_config_common`, with an error message naming both fields.
- [x] 1.3 Add the `dynamic "remote_repository_config"` block rendering `common_repository`, with the same empty-description fallback to the repository description as the docker block.
- [x] 1.4 Guard the existing docker `remote_repository_config` block on `remote_repository_config_docker != null`, so the two blocks are mutually exclusive at render time.
- [x] 1.5 Make `local.remote_repositories` and `data.google_secret_manager_secret_version.remote_repository_secrets` tolerate a null docker configuration: the `lookup(repository.remote_repository_config_docker, ...)` calls in `main.tf:118-126` run for every `REMOTE_REPOSITORY` repository.
- [x] 1.6 Document the cross-project prerequisites in a hand-written `README.md` section above the terraform-docs marker: the accepted `uri` shapes, the standard-mode upstream requirement, the `roles/artifactregistry.serviceAgent` grant the upstream owner makes before the remote repository is created (with the `gcloud` command), that the role is not read-only, `disable_upstream_validation` as the escape hatch, and the cleanup-policy caveat for a cache. The variable description carries the short form and points here.

## 2. Service agent grant

- [x] 2.1 Add `service_agents = optional(list(string), [])` to the `repositories` object type in `variables.tf`, documenting that `roles/artifactregistry.serviceAgent` includes `artifactregistry.versions.delete` and belongs at repository scope only.
- [x] 2.2 Extend `local.member_and_role_per_repo` with a third branch mapping `service_agents` to `roles/artifactregistry.serviceAgent`, keeping the existing `"<repository>--<role>--<member>"` key shape.
- [x] 2.3 Verify no state address changes for existing `readers` and `writers` bindings. Verified by a plan-time test asserting the exact key set of `google_artifact_registry_repository_iam_member.member` for a repository with only `readers` and `writers`, and by a test proving the same member in two roles yields two distinct bindings. A plan against real state was not run: the module has no test project or credentials, and the key already contains the role (`main.tf`), so no existing address can change.

## 3. Service agent member output

- [x] 3.1 Add a `google_project` data source gated on at least one repository using `remote_repository_config_common`.
- [x] 3.2 Add an output returning `serviceAccount:service-<project_number>@gcp-sa-artifactregistry.iam.gserviceaccount.com`, `null` when the data source is not created, with a description stating that this is the member an upstream repository owner must grant `roles/artifactregistry.serviceAgent` to.

## 4. Example, docs, changelog

- [x] 4.1 Add to `examples/test.tfvars` a `REMOTE_REPOSITORY` repository using `remote_repository_config_common` with an Artifact Registry resource path upstream (`project-4-remote-artifact-registry`), and a standard repository carrying a `service_agents` entry (`project-5-shared-upstream`).
- [x] 4.2 Update `examples/README.md` to describe the two new sample repositories.
- [x] 4.3 Regenerate the terraform-docs block in `README.md` (`make generate-docs`).
- [x] 4.4 Add `CHANGELOG.md` entries under `## [Unreleased]` / `### Changed`, following the repository's `- FEAT (refs ...):` convention, one bullet per feature, noting that a consumer which declares its own copy of the `repositories` object type must mirror the new fields before it can use them.

## 5. Tests

- [x] 5.1 `make lint` passes with the extended example.
- [x] 5.2 `make tfsec` passes with the extended example.
- [x] 5.3 Add `tests/remote_repository.tftest.hcl` with `mock_provider "google"` and `command = plan` runs asserting the `common_repository` rendering, the unchanged docker rendering including the `DOCKER_HUB` branch, and both validation failures via `expect_failures`. Add `tests/repository_iam.tftest.hcl` covering the `service_agents` grant, the unchanged binding addresses when the list is empty, and the same member in two roles.
- [x] 5.4 Add a `terraform test` job to `.github/workflows/`, pinning a Terraform version >= 1.7, without changing the module's `required_version`.

## 6. Release

- [ ] 6.1 Release `0.16.0` after review.
- [ ] 6.2 Verify the implementation against this change (`openspec validate`) and archive it.
