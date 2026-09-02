# Delta: service-agent-repository-grants

## ADDED Requirements

### Requirement: Service agent grants on a repository

Each entry of `var.repositories` SHALL accept an optional `service_agents` field
(list of strings, default `[]`). For every principal in the list the module SHALL create a
`google_artifact_registry_repository_iam_member` binding on that repository with role
`roles/artifactregistry.serviceAgent`. The binding SHALL be scoped to the repository, never
to the project. The field is the surface an upstream repository's owner uses to let a
consumer project's Artifact Registry Service Agent fill a pull-through cache from that
repository.

The module SHALL NOT verify that a listed principal is an Artifact Registry Service Agent;
the value is passed through as an IAM member string, consistently with `readers` and
`writers`.

#### Scenario: Grant declared on an upstream repository

- **WHEN** a standard repository declares
  `service_agents = ["serviceAccount:service-000000000000@gcp-sa-artifactregistry.iam.gserviceaccount.com"]`
- **THEN** the plan contains one `google_artifact_registry_repository_iam_member` for that
  repository with `role = "roles/artifactregistry.serviceAgent"` and that member

#### Scenario: Default empty list changes nothing

- **WHEN** no repository declares `service_agents`
- **THEN** the set of `google_artifact_registry_repository_iam_member` resources is
  identical to the set produced before this change, with unchanged resource addresses

#### Scenario: Same principal in two roles

- **WHEN** the same member appears in both `readers` and `service_agents` of one repository
- **THEN** two distinct bindings are planned, one per role, with distinct resource
  addresses

### Requirement: Documented privilege of the service agent role

The `repositories` variable description and `README.md` SHALL state that
`roles/artifactregistry.serviceAgent` is not read-only: it includes
`artifactregistry.versions.delete`, so a principal listed in `service_agents` can delete
versions in that repository. The documentation SHALL direct the reader to grant it only
where an Artifact Registry upstream requires it, and only at repository scope.

#### Scenario: Documentation states the privilege

- **WHEN** `README.md` is regenerated after this change
- **THEN** it states that `roles/artifactregistry.serviceAgent` includes version deletion
  and that the grant belongs at repository scope
