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

## [0.2.0] - 2023-05-18

### Added

- FEATURE: if the `artifact_registry_listers` is provided, a new custom IAM role is created and assigned to the `artifact_registry_listers` principals, allowing them to list the artifacts repositories.

### Changed

- FEATURE: the `location` in the `repositories` structure is now optional, and if it is not provided the repository will be cloned in the `default_location` location.

## [0.1.0] - 2023-04-11

- Init project.
