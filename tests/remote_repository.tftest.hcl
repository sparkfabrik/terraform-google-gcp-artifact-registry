# Plan-time tests for the remote repository configurations. The provider is mocked, so
# these runs need no credentials and create no cloud resources.

mock_provider "google" {}

variables {
  project_id = "test-project"
}

# An Artifact Registry upstream renders common_repository and nothing else.
run "common_repository_upstream" {
  command = plan

  variables {
    repositories = {
      "ar-cache" = {
        description = "Pull-through cache"
        mode        = "REMOTE_REPOSITORY"
        remote_repository_config_common = {
          uri = "projects/upstream-project/locations/europe-west1/repositories/upstream-repo"
        }
      }
    }
  }

  override_data {
    target = data.google_project.project[0]
    values = {
      number = "123456789012"
    }
  }

  assert {
    condition     = google_artifact_registry_repository.repositories["ar-cache"].remote_repository_config[0].common_repository[0].uri == "projects/upstream-project/locations/europe-west1/repositories/upstream-repo"
    error_message = "common_repository.uri was not rendered from remote_repository_config_common.uri"
  }

  assert {
    condition     = length(google_artifact_registry_repository.repositories["ar-cache"].remote_repository_config[0].docker_repository) == 0
    error_message = "a docker_repository block was rendered for an Artifact Registry upstream"
  }

  assert {
    condition     = length(google_artifact_registry_repository.repositories["ar-cache"].remote_repository_config[0].upstream_credentials) == 0
    error_message = "an upstream_credentials block was rendered for an Artifact Registry upstream"
  }

  assert {
    condition     = google_artifact_registry_repository.repositories["ar-cache"].remote_repository_config[0].description == "Pull-through cache"
    error_message = "an empty remote description did not fall back to the repository description"
  }

  assert {
    condition     = google_artifact_registry_repository.repositories["ar-cache"].remote_repository_config[0].disable_upstream_validation == false
    error_message = "disable_upstream_validation did not default to false"
  }

  assert {
    condition     = output.artifact_registry_service_agent_member == "serviceAccount:service-123456789012@gcp-sa-artifactregistry.iam.gserviceaccount.com"
    error_message = "the service agent member output was not derived from the project number"
  }
}

# The remote description and the upstream validation switch are passed through.
run "common_repository_overrides" {
  command = plan

  variables {
    repositories = {
      "ar-cache" = {
        description = "Pull-through cache"
        mode        = "REMOTE_REPOSITORY"
        remote_repository_config_common = {
          description                 = "Upstream: another Artifact Registry repository"
          uri                         = "https://europe-west1-docker.pkg.dev/upstream-project/upstream-repo"
          disable_upstream_validation = true
        }
      }
    }
  }

  assert {
    condition     = google_artifact_registry_repository.repositories["ar-cache"].remote_repository_config[0].description == "Upstream: another Artifact Registry repository"
    error_message = "an explicit remote description was not used"
  }

  assert {
    condition     = google_artifact_registry_repository.repositories["ar-cache"].remote_repository_config[0].disable_upstream_validation == true
    error_message = "disable_upstream_validation was not passed through"
  }
}

# The Docker Hub upstream renders exactly as it did before common_repository existed.
run "docker_hub_upstream_unchanged" {
  command = plan

  variables {
    repositories = {
      "dockerhub" = {
        description = "Docker Hub mirror"
        mode        = "REMOTE_REPOSITORY"
        remote_repository_config_docker = {
          custom_repository_uri                                 = "DOCKER_HUB"
          username_password_credentials_username                = "someone"
          username_password_credentials_password_secret_name    = "dockerhub-credentials"
          username_password_credentials_password_secret_version = "latest"
        }
      }
    }
  }

  override_data {
    target = data.google_secret_manager_secret_version.remote_repository_secrets["dockerhub"]
    values = {
      secret = "dockerhub-credentials"
    }
  }

  assert {
    condition     = google_artifact_registry_repository.repositories["dockerhub"].remote_repository_config[0].docker_repository[0].public_repository == "DOCKER_HUB"
    error_message = "the DOCKER_HUB public upstream was not rendered"
  }

  assert {
    condition     = length(google_artifact_registry_repository.repositories["dockerhub"].remote_repository_config[0].common_repository) == 0
    error_message = "a common_repository block was rendered for a docker upstream"
  }

  assert {
    condition     = google_artifact_registry_repository.repositories["dockerhub"].remote_repository_config[0].description == "Docker Hub mirror"
    error_message = "an empty docker remote description did not fall back to the repository description"
  }

  assert {
    condition     = google_artifact_registry_repository.repositories["dockerhub"].remote_repository_config[0].upstream_credentials[0].username_password_credentials[0].password_secret_version == "projects/test-project/secrets/dockerhub-credentials/versions/latest"
    error_message = "the Secret Manager version reference changed shape"
  }

  assert {
    condition     = output.artifact_registry_service_agent_member == null
    error_message = "the service agent member output is not null when no repository uses an Artifact Registry upstream"
  }
}

# A custom registry upstream renders exactly as it did before common_repository existed.
run "custom_registry_upstream_unchanged" {
  command = plan

  variables {
    repositories = {
      "ghcr" = {
        description = "GitHub Container Registry mirror"
        mode        = "REMOTE_REPOSITORY"
        remote_repository_config_docker = {
          custom_repository_uri = "https://ghcr.io"
        }
      }
    }
  }

  assert {
    condition     = google_artifact_registry_repository.repositories["ghcr"].remote_repository_config[0].docker_repository[0].custom_repository[0].uri == "https://ghcr.io"
    error_message = "custom_repository.uri was not rendered from custom_repository_uri"
  }

  assert {
    condition     = length(google_artifact_registry_repository.repositories["ghcr"].remote_repository_config[0].common_repository) == 0
    error_message = "a common_repository block was rendered for a docker upstream"
  }
}

# A remote repository with both configurations is rejected at plan time.
run "both_remote_configurations_rejected" {
  command = plan

  variables {
    repositories = {
      "invalid" = {
        description = "Two upstreams"
        mode        = "REMOTE_REPOSITORY"
        remote_repository_config_docker = {
          custom_repository_uri = "https://ghcr.io"
        }
        remote_repository_config_common = {
          uri = "projects/upstream-project/locations/europe-west1/repositories/upstream-repo"
        }
      }
    }
  }

  expect_failures = [var.repositories]
}

# A remote repository with no configuration is rejected at plan time.
run "no_remote_configuration_rejected" {
  command = plan

  variables {
    repositories = {
      "invalid" = {
        description = "No upstream"
        mode        = "REMOTE_REPOSITORY"
      }
    }
  }

  expect_failures = [var.repositories]
}

# A standard repository needs no remote configuration.
run "standard_repository_unaffected" {
  command = plan

  variables {
    repositories = {
      "images" = {
        description = "Docker images"
      }
    }
  }

  assert {
    condition     = length(google_artifact_registry_repository.repositories["images"].remote_repository_config) == 0
    error_message = "a remote_repository_config block was rendered for a standard repository"
  }
}

# An explicit docker remote description wins over the repository description.
run "docker_explicit_description_wins" {
  command = plan

  variables {
    repositories = {
      "ghcr" = {
        description = "GitHub Container Registry mirror"
        mode        = "REMOTE_REPOSITORY"
        remote_repository_config_docker = {
          description           = "Upstream: ghcr.io"
          custom_repository_uri = "https://ghcr.io"
        }
      }
    }
  }

  assert {
    condition     = google_artifact_registry_repository.repositories["ghcr"].remote_repository_config[0].description == "Upstream: ghcr.io"
    error_message = "an explicit docker remote description was not used"
  }
}

# A remote configuration on a repository that is not in REMOTE_REPOSITORY mode would be
# silently ignored, so it is rejected at plan time.
run "common_configuration_outside_remote_mode_rejected" {
  command = plan

  variables {
    repositories = {
      "images" = {
        description = "Docker images"
        remote_repository_config_common = {
          uri = "projects/upstream-project/locations/europe-west1/repositories/upstream-repo"
        }
      }
    }
  }

  expect_failures = [var.repositories]
}

run "docker_configuration_outside_remote_mode_rejected" {
  command = plan

  variables {
    repositories = {
      "images" = {
        description = "Docker images"
        remote_repository_config_docker = {
          custom_repository_uri = "https://ghcr.io"
        }
      }
    }
  }

  expect_failures = [var.repositories]
}

# An empty upstream uri is rejected at plan time instead of failing at apply time.
run "empty_upstream_uri_rejected" {
  command = plan

  variables {
    repositories = {
      "ar-cache" = {
        description = "Pull-through cache"
        mode        = "REMOTE_REPOSITORY"
        remote_repository_config_common = {
          uri = ""
        }
      }
    }
  }

  expect_failures = [var.repositories]
}

run "blank_upstream_uri_rejected" {
  command = plan

  variables {
    repositories = {
      "ar-cache" = {
        description = "Pull-through cache"
        mode        = "REMOTE_REPOSITORY"
        remote_repository_config_common = {
          uri = "   "
        }
      }
    }
  }

  expect_failures = [var.repositories]
}
