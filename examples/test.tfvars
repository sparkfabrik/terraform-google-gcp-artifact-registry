project_id = "my-sample-project-id"

repositories = {
  "project-images" = {
    description = "Docker images repository"
    cleanup_policies = {
      "custom-policy" = {
        action = "DELETE"
        condition = {
          tag_state  = "UNTAGGED"
          older_than = "2592000s" # 30 days
        }
      }
    }
    readers = [
      "group:dev-team@example.com"
    ]
    writers = [
      "user:admin@example.com"
    ]
    location = "europe-west1"
  },
  "project-2-virtual" = {
    description                     = "Docker images repository 2"
    mode                            = "VIRTUAL_REPOSITORY"
    cleanup_policies_enable_default = false
    virtual_repository_config = {
      "my-repository-upstream-1" = {
        repository = "projects/p1/locations/us-central1/repository/repo1"
        priority   = 10
      }
      "my-repository-upstream-2" = {
        repository = "projects/p1/locations/us-central1/repository/repo2"
      }
    }
    readers = [
      "group:dev-team-2@example.com"
    ]
    writers = [
      "user:admin@example.com"
    ]
  }
  "project-3-remote" = {
    description = "Docker images repository 3"
    mode        = "REMOTE_REPOSITORY"
    remote_repository_config_docker = {
      description           = "Docker images repository 3"
      custom_repository_uri = "https://registry-1.docker.io"
    }
    readers = [
      "group:dev-team-2@example.com"
    ]
    writers = [
      "user:admin@example.com"
    ]
  }
  "project-4-remote-artifact-registry" = {
    description = "Pull-through cache of another Artifact Registry repository"
    mode        = "REMOTE_REPOSITORY"
    location    = "europe-west1"
    remote_repository_config_common = {
      uri = "projects/upstream-project/locations/europe-west1/repositories/upstream-repo"
    }
    # A cache whose consumers pin digests must not evict cached versions.
    cleanup_policies_enable_default = false
    readers = [
      "group:dev-team-2@example.com"
    ]
  }
}
