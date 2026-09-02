# Example

Create two sample Artifact Registry registry in `my-sample-project-id` project:

- project-images

  the group dev-team@example.com can read the repository, only admin@example.com user can write

- project-2-virtual (virtual repository)

  the group dev-team-2@example.com can read the repository, only admin@example.com user can write

- project-3-remote (remote repository)
  
  the group dev-team-2@example.com can read the repository, only admin@example.com user can write

- project-4-remote-artifact-registry (remote repository with an Artifact Registry upstream)

  a pull-through cache of `upstream-project/upstream-repo`, reached as the project's Artifact Registry service agent with no stored credentials. The default cleanup policies are disabled so the cache never evicts a version its consumers pin. The group dev-team-2@example.com can read the repository.

- project-5-shared-upstream (standard repository shared as an upstream)

  the group dev-team@example.com can read the repository, and the Artifact Registry service agent listed in `service_agents` can fill another project's remote repository cache from it. That grant is `roles/artifactregistry.serviceAgent`, which is not read-only.
