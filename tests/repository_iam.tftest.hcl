# Plan-time tests for the per-repository IAM bindings. The provider is mocked, so these
# runs need no credentials and create no cloud resources.

mock_provider "google" {}

variables {
  project_id = "test-project"
}

# A service_agents entry grants roles/artifactregistry.serviceAgent on that repository.
run "service_agent_grant" {
  command = plan

  variables {
    repositories = {
      "shared-artifacts" = {
        description = "Shared upstream"
        service_agents = [
          "serviceAccount:service-123456789012@gcp-sa-artifactregistry.iam.gserviceaccount.com",
        ]
      }
    }
  }

  assert {
    condition     = length(google_artifact_registry_repository_iam_member.member) == 1
    error_message = "a service_agents entry did not produce exactly one IAM binding"
  }

  assert {
    condition     = google_artifact_registry_repository_iam_member.member["shared-artifacts--roles/artifactregistry.serviceAgent--serviceAccount:service-123456789012@gcp-sa-artifactregistry.iam.gserviceaccount.com"].role == "roles/artifactregistry.serviceAgent"
    error_message = "the binding was not keyed and roled as expected"
  }

  assert {
    condition     = google_artifact_registry_repository_iam_member.member["shared-artifacts--roles/artifactregistry.serviceAgent--serviceAccount:service-123456789012@gcp-sa-artifactregistry.iam.gserviceaccount.com"].member == "serviceAccount:service-123456789012@gcp-sa-artifactregistry.iam.gserviceaccount.com"
    error_message = "the binding member was not passed through"
  }
}

# An empty service_agents list leaves the reader and writer bindings, and their resource
# addresses, exactly as they were before the field existed.
run "default_empty_list_changes_nothing" {
  command = plan

  variables {
    repositories = {
      "images" = {
        description = "Docker images"
        readers     = ["group:dev-team@example.com"]
        writers     = ["user:admin@example.com"]
      }
    }
  }

  assert {
    condition     = length(google_artifact_registry_repository_iam_member.member) == 2
    error_message = "an empty service_agents list added or removed a binding"
  }

  assert {
    condition = toset(keys(google_artifact_registry_repository_iam_member.member)) == toset([
      "images--roles/artifactregistry.reader--group:dev-team@example.com",
      "images--roles/artifactregistry.writer--user:admin@example.com",
    ])
    error_message = "the reader and writer binding addresses changed shape"
  }
}

# The same principal in two roles produces two distinct bindings, because the map key
# already contains the role.
run "same_member_in_two_roles" {
  command = plan

  variables {
    repositories = {
      "shared-artifacts" = {
        description    = "Shared upstream"
        readers        = ["serviceAccount:service-123456789012@gcp-sa-artifactregistry.iam.gserviceaccount.com"]
        service_agents = ["serviceAccount:service-123456789012@gcp-sa-artifactregistry.iam.gserviceaccount.com"]
      }
    }
  }

  assert {
    condition     = length(google_artifact_registry_repository_iam_member.member) == 2
    error_message = "the same member in two roles collapsed into one binding"
  }

  assert {
    condition = toset([for binding in google_artifact_registry_repository_iam_member.member : binding.role]) == toset([
      "roles/artifactregistry.reader",
      "roles/artifactregistry.serviceAgent",
    ])
    error_message = "the two bindings do not carry one role each"
  }
}
