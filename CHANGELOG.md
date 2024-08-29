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
