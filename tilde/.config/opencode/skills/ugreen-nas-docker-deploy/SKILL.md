---
name: ugreen-nas-docker-deploy
description: Deploy Docker images to the UGREEN NAS and replace a running container or Compose application. Use when asked to push, deploy, release, or update a Docker image or application on ugreen-nas.
---

# UGREEN NAS Docker Deployment

Deploy to the Tailscale target `ugreen-nas` through `ugos-cli` and the `ugos`
MCP server. UGOS uses HTTPS port `9443`; `http://ugreen-nas/` is only the web
dashboard. The configured DXP4800 Plus has an Intel CPU, so its Docker target
platform is `linux/amd64`.

## Required Inputs

Before changing the NAS, establish:

- The local image to deploy, or the Dockerfile/build context and desired image
  reference.
- The application name and whether it is a standalone container or a Compose
  project.
- For Compose, the authoritative local Compose file and service to update.
- The target platform. Use the confirmed `linux/amd64` for this NAS unless the
  existing application metadata requires something more specific.
- An application-specific verification command, URL, health check, or expected
  log message when one is available.

Ask one concise question for any missing input. Never ask the user to disclose
the NAS password in chat.

## Safety Rules

- Run read-only discovery before making changes.
- Use an immutable image tag, preferably including the Git commit. Do not deploy
  an unqualified or moving `latest` tag unless the user explicitly requests it.
- Capture the current container/project metadata, full standalone container
  spec, running state, image ID/reference, and recent logs before replacement.
- Keep the old image and captured configuration until the new application has
  passed verification.
- Explain the exact replacement and rollback actions, then obtain confirmation
  immediately before stopping or removing a running application.
- Never use `--tls-insecure`. On first contact, stop after the read-only probe so
  the user can verify the certificate fingerprint printed by `ugos-cli` before
  any mutation.
- Never remove Compose images during replacement: omit `--del-images`.
- If a command fails, stop the sequence, report the failing step, and either
  preserve the old running application or offer the captured rollback.

## Preflight

1. Require `ugos-cli`, `ugos-mcp`, `docker`, `UGOS_USER`, and `UGOS_PASSWORD`.
   If the password is absent, instruct the user to run `ugos-password-set` in an
   interactive shell and restart OpenCode. Do not continue without credentials.
2. Record `ugos-cli --version`; tool capabilities can change between releases.
3. Confirm Tailscale reachability with `tailscale ping ugreen-nas`.
4. Probe the API read-only with `ugos-cli system info`, then confirm the Docker
   engine with `ugos-cli docker status`.
5. Discover the application with JSON output:

   ```sh
   ugos-cli -o json docker ps
   ugos-cli -o json docker project-ls
   ugos-cli -o json docker images
   ```

6. Classify an application with a non-empty `projectName` as Compose. Never
   replace one of its containers as though it were standalone.

## Build And Transfer

1. Build or retag the image with an immutable reference. Follow the repository's
   existing build command when present. Otherwise use Docker or Buildx with the
   confirmed target platform.
2. Inspect the local image and record its ID and architecture:

   ```sh
   docker image inspect IMAGE_REF
   ```

3. Create a temporary directory and archive without modifying the repository:

   ```sh
   work_dir="$(mktemp -d)"
   archive="$work_dir/image.tar"
   docker image save -o "$archive" IMAGE_REF
   ```

4. Select a writable NAS volume from `ugos-cli -o json fs volumes`. Use a
   dedicated directory such as `/volume1/docker/.opencode-deploy`, creating it
   only if needed. Do not assume `volume1` when discovery reports another
   volume.
5. Upload and load the archive:

   ```sh
   ugos-cli fs put "$archive" REMOTE_DIRECTORY
   ugos-cli docker load-path REMOTE_ARCHIVE_PATH
   ```

6. Poll `ugos-cli -o json docker images` until the exact immutable reference and
   expected image ID are present. Loading is asynchronous; an accepted request
   is not proof that loading completed.

## Standalone Replacement

If the installed `ugos-cli` does not expose its library's update operation (as
with v0.14.2), use the MCP server's full-spec tools to preserve settings while
recreating the container. If a later CLI adds an update operation, inspect its
current help before using it and preserve the same rollback guarantees below.

1. Resolve the container ID from `ugos-cli -o json docker ps`.
2. Call `ugos_docker_show` and retain its complete JSON as the rollback spec.
   Record whether the container was running and fetch recent logs.
3. Copy the full spec and change only the image fields required by the returned
   schema (`imageName`, `imageId`, `imageVersion`, and `tag`). Set
   `runContainer` to the original running state. Preserve ports, volumes,
   environment, command, network, resources, privileges, GPU IDs, and restart
   behavior exactly.
4. Show a concise old-image/new-image diff and ask for confirmation.
5. Stop the old container when running, remove it, then call
   `ugos_docker_create` with the new full spec. Removal is required because the
   replacement keeps the same container name.
6. If creation or verification fails, remove any failed replacement and call
   `ugos_docker_create` with the captured original spec. Start it if it was
   previously running, then verify the rollback.

## Compose Replacement

1. Call `ugos_project_show` and record the project path, status, containers,
   image references, and recent logs.
2. Require the authoritative local Compose file. Create a temporary copy and
   update only the selected service to the immutable image reference. Do not
   silently alter the user's source Compose file.
3. Validate the temporary file with `docker compose -f TEMP_FILE config`.
4. Show the image diff and ask for confirmation.
5. Recreate the project at the same name and NAS path:

   ```sh
   ugos-cli docker project-rm PROJECT_NAME
   ugos-cli docker project-create PROJECT_NAME --file TEMP_FILE --path PROJECT_PATH --run
   ```

   A restart alone is insufficient because it does not recreate containers on
   the newly loaded image.
6. If recreation or verification fails, recreate the project from the captured
   original Compose content or known-good local Compose file using its previous
   immutable image references. If that content is unavailable, do not remove
   the running project in the first place.

## Verification And Cleanup

1. Poll `docker ps` or `project-show` until every expected container is running.
2. Confirm each container reports the new immutable image reference or image ID.
3. Inspect recent logs and run the application-specific health check.
4. Report the old and new image references, resulting container IDs, and health
   check result.
5. Only after success, permanently remove the uploaded archive from the NAS and
   delete the local temporary directory. Keep the previous Docker image unless
   the user separately requests cleanup after the rollback window.
