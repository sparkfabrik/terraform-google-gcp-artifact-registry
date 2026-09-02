# Proposal: Artifact Registry upstream support for remote repositories

## Why

The module can create a remote repository (a pull-through cache) only against an external
registry URL. It wires `remote_repository_config.docker_repository.custom_repository.uri`
from the `custom_repository_uri` input, with a special case for the `DOCKER_HUB` public
upstream (`main.tf:194-229`). It exposes no way to set another Artifact Registry
repository as the upstream.

Two facts make this a gap rather than a preference:

- The Artifact Registry API rejects a repository resource path on the `custom_repository`
  path. Passing `projects/UPSTREAM_PROJECT_ID/locations/REGION/repositories/UPSTREAM_REPOSITORY`
  fails with `Custom remote repository URI must start with 'http://' or 'https://'`. The
  Artifact Registry upstream lives in a different union member, `commonRepository`.
- The provider marks the field the module uses as superseded:
  `docker_repository.custom_repository` carries
  `[Deprecated, please use commonRepository instead]`.

An Artifact Registry upstream also authenticates differently. It uses the requesting
project's Artifact Registry Service Agent, so the read path stores no credentials, while
`custom_repository` is the credentialed path for arbitrary external registries.

The same gap exists on the other side of the relationship. The grant that lets a cache
fill itself is `roles/artifactregistry.serviceAgent` on the upstream repository, and the
module can only grant `roles/artifactregistry.reader` (`readers`) and
`roles/artifactregistry.writer` (`writers`). A repository created by this module therefore
cannot be declared as the upstream of another project's cache without an out-of-band IAM
change that no Terraform plan will show.

Issue: platform/#4903

## What Changes

- **Upstream configuration.** Add a per-repository `remote_repository_config_common`
  input and render `remote_repository_config.common_repository` from it. The input carries
  the upstream `uri`, an optional `description`, and `disable_upstream_validation`. It is
  format-agnostic, matching the API union member, so it also unblocks remote repositories
  for npm, Maven and Python Artifact Registry upstreams that the module cannot express
  today.
- **Service agent grant.** Add a per-repository `service_agents` list that grants
  `roles/artifactregistry.serviceAgent` on the repository, so the owner of a repository
  used as an upstream can declare the cache-fill grant for a consumer project in
  Terraform.
- **Output.** Add an output carrying the module project's Artifact Registry Service Agent
  IAM member string, so a consumer can hand the exact member to the upstream owner without
  deriving the project number by hand.
- **Validation.** A `REMOTE_REPOSITORY` repository must declare exactly one of
  `remote_repository_config_docker` and `remote_repository_config_common`. The existing
  rule (a remote repository must declare a remote configuration) is preserved.
- **Docs, example and tests.** Extend `examples/test.tfvars` with an Artifact Registry
  upstream and a service agent grant, regenerate the terraform-docs block, add a CHANGELOG
  entry, and add plan-time tests for the new rendering and the new validation.

Out of scope:

- Migrating the existing `custom_repository_uri` path to `common_repository` for external
  registries. `common_repository` also accepts registry URLs and is the non-deprecated
  path, but moving existing consumers across is a separate, potentially breaking change.
- Upstream credentials on the common configuration. An Artifact Registry upstream needs
  none, and the credentialed path already exists on the docker configuration.
- Format-specific remote blocks (`npm_repository`, `maven_repository`,
  `python_repository`, `apt_repository`, `yum_repository`) and the `no_cache` connector
  mode.

## Capabilities

### New Capabilities

- `ar-upstream-remote-repository`: a repository in `REMOTE_REPOSITORY` mode can declare
  another Artifact Registry repository as its upstream, in the same or a different
  project, with no stored credentials.
- `service-agent-repository-grants`: a repository can grant
  `roles/artifactregistry.serviceAgent` to named principals, which is the grant the owner
  of an upstream repository has to make for a consumer project's cache to fill.

## Impact

- `variables.tf`: new `remote_repository_config_common` and `service_agents` fields on the
  `repositories` object; the `REMOTE_REPOSITORY` validation is extended.
- `main.tf`: new `dynamic "common_repository"` rendering, extended IAM member map, gated
  `google_project` data source for the service agent member string.
- `outputs.tf`: new service agent member output.
- `examples/`, `README.md`, `CHANGELOG.md`, and a new `tests/` directory with a CI job.
- No provider version bump. `common_repository` landed in `hashicorp/google` 6.12.0 and the
  module already requires `>= 6.15.0`.
- Additive and backwards compatible: a repository that sets neither new field renders the
  same resource arguments as before. A consumer that declares its own copy of the
  `repositories` object type has to add the new fields to that copy before it can pass
  them, which is a consumer-side edit, not a break.
- Release: minor version (`0.16.0`).
