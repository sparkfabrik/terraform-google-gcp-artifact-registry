# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Use this convention to add annotations about the [different sections](https://keepachangelog.com/en/1.0.0/#how):

- [TYPE] - refs [#000](https://gitlab.sparkfabrik.com): Description of fix, feature or change.

where with [TYPE] we mean

- _FIX_ for a bugfix;
- _FEATURE_ if the change introduces a new backwards compatible feature.
- _BREAKING_ if the change introduces a new non backwards compatible feature.

A feature is backwards compatible if it does not require any manual intervention to the project.
Following semver, any non backwards compatible feature implies that the next release is a major one, and any manual step must be documented in the `UPGRADING.md` file.

## [Unreleased]

## [0.10.1] - 2025-03-04

[Compare with previous version](https://github.com/sparkfabrik/terraform-google-gcp-artifact-registry/compare/0.10.0...0.10.1)

### Changed

- FIX: typo `var.var.repositories` in `outputs.tf`

## [0.10.0] - 2025-02-28

[Compare with previous version](https://github.com/sparkfabrik/terraform-google-gcp-artifact-registry/compare/0.9.0...0.10.0)

### Added

- FEAT: add the `repositories_data` output to expose the calculated data of the created repositories.

## [0.9.0] - 2025-02-11

[Compare with previous version](https://github.com/sparkfabrik/terraform-google-gcp-artifact-registry/compare/0.8.0...0.9.0)

:warning: **This release contains breaking changes.** If you rely on the previous `docker_immutable_tags` variable default value (`true`), you must update your configuration to set it explicitly. **Now the default value is `false`.**

### Changed

- BREAKING: The `docker_immutable_tags` variable (`docker_config.immutable_tags` configuration of the `google_artifact_registry_repository` resource) has been changed to `false` by default. This is a breaking change if you were relying on the previous default value of true.
- FEAT: add `additional_labels` variable to add custom labels to the artifact registry repositories.

## [0.8.0] - 2024-10-17

[Compare with previous version](https://github.com/sparkfabrik/terraform-google-gcp-artifact-registry/compare/0.7.1...0.8.0)

### Changed

- FEAT: Add labels to artifact registry repositories

## [0.7.1] - 2024-10-17

[Compare with previous version](https://github.com/sparkfabrik/terraform-google-gcp-artifact-registry/compare/0.7.0...0.7.1)

### Changed

- FIX: use the value of `username_password_credentials_password_secret_version` instead of data output to keep `latest` as version for secret.

## [0.7.0] - 2024-10-15

[Compare with previous version](https://github.com/sparkfabrik/terraform-google-gcp-artifact-registry/compare/0.6.0...0.7.0)

### Added

- BREAKING: add support for GCP secret as password for remote repositories. Break backwards compatibility if using `username_password_credentials_password_secret_version` as it now stores the secret version (not the name).

## [0.6.0] - 2024-10-09

[Compare with previous version](https://github.com/sparkfabrik/terraform-google-gcp-artifact-registry/compare/0.5.0...0.6.0)

### Added

- FEATURE: add support for mirror public registry (Docker Hub) if `custom_repository_uri` is `DOCKER_HUB`

## [0.5.0] - 2024-08-29

[Compare with previous version](https://github.com/sparkfabrik/terraform-google-gcp-artifact-registry/compare/0.4.0...0.5.0)

### Added

- FEATURE: add the cleanup policies management for the repositories.

## [0.4.0] - 2024-05-02

[Compare with previous version](https://github.com/sparkfabrik/terraform-google-gcp-artifact-registry/compare/0.3.0...0.4.0)

- FEATURE: add the `enable_api` variable to enable the Artifact Registry API only if needed.
- FIX: enable the `docker_config` block if the `format` is `DOCKER` and the `mode` is `STANDARD_REPOSITORY`.

## [0.3.0] - 2024-05-02

[Compare with previous version](https://github.com/sparkfabrik/terraform-google-gcp-artifact-registry/compare/0.2.1...0.3.0)

### Changed

- FEATURE: Create an artifact registry repository in remote or virtual mode
- FEATURE: Upgrade `hashicorp/google` provider to `>= 5.26.0`

## [0.2.1] - 2023-05-19

[Compare with previous version](https://github.com/sparkfabrik/terraform-google-gcp-artifact-registry/compare/0.2.0...0.2.1)

### Changed

- FIX: the `artifact_registry_listers_custom_role_name` variable is configured as `custom.artifactRegistryLister` by default. The previous default value was `custom.artifactRegistryListers`.

## [0.2.0] - 2023-05-18

[Compare with previous version](https://github.com/sparkfabrik/terraform-google-gcp-artifact-registry/compare/0.1.0...0.2.0)

### Added

- FEATURE: if the `artifact_registry_listers` is provided, a new custom IAM role is created and assigned to the `artifact_registry_listers` principals, allowing them to list the artifacts repositories.

### Changed

- FEATURE: the `location` in the `repositories` structure is now optional, and if it is not provided the repository will be cloned in the `default_location` location.

## [0.1.0] - 2023-04-11

- Init project.
