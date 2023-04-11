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
  "project-2-images" = {
    description = "Docker images repository 2"
    readers = [
      "group:dev-team-2@example.com"
    ]
    writers = [
      "user:admin@example.com"
    ]
    location = "europe-west1"
  }  
}
