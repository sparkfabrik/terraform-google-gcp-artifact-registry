# Delta: ar-upstream-remote-repository

## ADDED Requirements

### Requirement: Artifact Registry upstream configuration

Each entry of `var.repositories` SHALL accept an optional
`remote_repository_config_common` object with the fields `description`
(string, default `""`), `uri` (string, required) and `disable_upstream_validation`
(bool, default `false`). When a repository sets it and its `mode` is
`REMOTE_REPOSITORY`, the module SHALL render
`remote_repository_config.common_repository.uri` from `uri`, SHALL render
`remote_repository_config.disable_upstream_validation` from
`disable_upstream_validation`, and SHALL NOT render a `docker_repository` block for that
repository. When `description` is empty, `remote_repository_config.description` SHALL fall
back to the repository's own `description`, matching the behaviour of the docker
configuration.

`uri` accepts an Artifact Registry resource path
(`projects/UPSTREAM_PROJECT_ID/locations/REGION/repositories/UPSTREAM_REPOSITORY`), an
Artifact Registry repository URL
(`https://REGION-docker.pkg.dev/UPSTREAM_PROJECT_ID/UPSTREAM_REPOSITORY`), or a registry
URI (`https://registry-1.docker.io`). The module SHALL NOT validate the shape of `uri`
beyond requiring a non-empty string; the API is the authority.

#### Scenario: Artifact Registry resource path upstream

- **WHEN** a repository is declared with `mode = "REMOTE_REPOSITORY"` and
  `remote_repository_config_common = { uri = "projects/upstream-project/locations/europe-west1/repositories/upstream-repo" }`
- **THEN** the planned `google_artifact_registry_repository` contains
  `remote_repository_config.common_repository.uri` equal to that path, contains no
  `docker_repository` block, and contains no `upstream_credentials` block

#### Scenario: Description falls back to the repository description

- **WHEN** a repository with `description = "Chart cache"` sets
  `remote_repository_config_common = { uri = "projects/p/locations/l/repositories/r" }`
  and leaves `remote_repository_config_common.description` empty
- **THEN** the planned `remote_repository_config.description` is `"Chart cache"`

#### Scenario: Upstream validation can be skipped

- **WHEN** a repository sets
  `remote_repository_config_common = { uri = "projects/p/locations/l/repositories/r", disable_upstream_validation = true }`
- **THEN** the planned `remote_repository_config.disable_upstream_validation` is `true`

### Requirement: Exactly one remote configuration

`var.repositories` validation SHALL reject, at plan time, any repository with
`mode = "REMOTE_REPOSITORY"` that sets neither `remote_repository_config_docker` nor
`remote_repository_config_common`, and any repository that sets both. The error message
SHALL name both fields. Repositories in any other mode SHALL be unaffected by this rule.

#### Scenario: Both remote configurations set

- **WHEN** a repository declares `mode = "REMOTE_REPOSITORY"` with both
  `remote_repository_config_docker` and `remote_repository_config_common`
- **THEN** `terraform plan` fails with a validation error naming both fields

#### Scenario: Neither remote configuration set

- **WHEN** a repository declares `mode = "REMOTE_REPOSITORY"` with neither field
- **THEN** `terraform plan` fails with a validation error naming both fields

#### Scenario: Standard repository unaffected

- **WHEN** a repository declares `mode = "STANDARD_REPOSITORY"` and neither field
- **THEN** `terraform plan` succeeds

### Requirement: Backwards compatibility of the docker remote path

For any repository that does not set `remote_repository_config_common`, the module SHALL
render the same resource arguments as before this change, including the `DOCKER_HUB`
public-repository branch, the `custom_repository.uri` branch, the
`upstream_credentials.username_password_credentials` block and its Secret Manager version
reference. `custom_repository_uri` SHALL remain a required attribute of
`remote_repository_config_docker`.

#### Scenario: Docker Hub mirror unchanged

- **WHEN** a repository declares `remote_repository_config_docker` with
  `custom_repository_uri = "DOCKER_HUB"`, a username and a password secret name
- **THEN** the planned resource contains
  `remote_repository_config.docker_repository.public_repository = "DOCKER_HUB"` and the
  `upstream_credentials` block, and contains no `common_repository` block

#### Scenario: Custom registry mirror unchanged

- **WHEN** a repository declares `remote_repository_config_docker` with
  `custom_repository_uri = "https://ghcr.io"`
- **THEN** the planned resource contains
  `remote_repository_config.docker_repository.custom_repository.uri = "https://ghcr.io"`
  and contains no `common_repository` block

### Requirement: Service agent member output

The module SHALL expose an output carrying the IAM member string of the Artifact Registry
Service Agent of `var.project_id`, in the form
`serviceAccount:service-<PROJECT_NUMBER>@gcp-sa-artifactregistry.iam.gserviceaccount.com`.
The project number SHALL be read from a `google_project` data source that is created only
when at least one repository sets `remote_repository_config_common`; the output SHALL be
`null` otherwise. The output description SHALL state that this is the member the owner of
an upstream repository must grant `roles/artifactregistry.serviceAgent` to.

#### Scenario: Output populated when the feature is used

- **WHEN** at least one repository sets `remote_repository_config_common`
- **THEN** the output is
  `serviceAccount:service-<project number>@gcp-sa-artifactregistry.iam.gserviceaccount.com`

#### Scenario: No new project read for existing consumers

- **WHEN** no repository sets `remote_repository_config_common`
- **THEN** no `google_project` data source is present in the plan and the output is `null`

### Requirement: Cross-project prerequisites are documented, not managed

The module SHALL NOT create IAM bindings in any project other than `var.project_id`. The
`repositories` variable description and `README.md` SHALL state that, when the upstream is
an Artifact Registry repository in another project, the upstream repository's owner must
grant `roles/artifactregistry.serviceAgent` on that repository to the consumer project's
Artifact Registry Service Agent before the remote repository is created, that the upstream
must be a standard-mode repository, and that `disable_upstream_validation` is the escape
hatch when the grant is not yet in place. The documentation SHALL also state that a
cleanup policy on a pull-through cache can evict a cached version that the upstream has
since deleted, making it unrecoverable, so `cleanup_policies_enable_default = false` is the
safer setting for a cache whose consumers pin digests.

#### Scenario: Documentation states the grant and its owner

- **WHEN** `README.md` is regenerated after this change
- **THEN** it names `roles/artifactregistry.serviceAgent`, the service agent member shape,
  the standard-mode upstream requirement, and the ordering requirement that the grant
  precedes repository creation
