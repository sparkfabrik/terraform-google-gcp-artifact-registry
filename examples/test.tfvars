project_id = "my-sample-project-id"

artifact_repositories = {
  "project-images" = {
    description = "Docker images repository"
    readers = [
      "group:dev-team@example.com"
    ]
    writers = [
      "user:admin@example.com"
    ]
    location = "europe-west1"
  },
  "project-2-virtual" = {
    description = "Docker images repository 2"
    mode        = "VIRTUAL_REPOSITORY"
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
}
