# Base Containers

This repository contains Docker Images that are automatically patched but with latest and predictable versions of applications installed.

These images are published to [DockerHub](https://hub.docker.com) under the namespace set using the `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN_RW` GitHub Secrets.

See the [Github Workflow](.github/workflows/build-push.yml) for specifics on each type of container built.

## Tags

Each image is published with the same tags to Docker Hub (`ybor/<name>`), `ghcr.io/p6m-dev/<name>`, and Artifactory (`p6m.jfrog.io/p6m-dev-docker/ybor/<name>` for OS-specific images, `p6m.jfrog.io/p6m-dev-docker/<name>` for the rest). Every image is built for `linux/amd64` and `linux/arm64` except `github-runner`, which is `linux/amd64` only. The tags come from the `docker/metadata-action` step in [`build-image.yaml`](.github/workflows/build-image.yaml), where `<version>` is the matrix entry's `version_tag`:

| Tag | Example | Moves? | Use it to |
|-----|---------|--------|-----------|
| `<version>` | `ybor/debian:trixie-slim` | Yes, on every build of `main`: push, weekly schedule, or manual run | Stay patched |
| `<version>-<YYYYMMDD>` | `ybor/debian:trixie-slim-20261022` | No, once its build day has passed; a second `main` build on the same day replaces it | Pin a known build |
| `<version>-<sha>` (7 or 40 characters) | `ybor/debian:trixie-slim-b40b340` | Yes, until the next commit lands: the weekly rebuild of an unchanged commit pushes a new image under the same tag | Trace an image to its commit; don't pin it |
| `<version>-pr-<number>` | `ybor/debian:trixie-slim-pr-43` | Yes, on every push to the pull request | Test a pull request; never deploy it |

The image digest (`ybor/debian@sha256:...`) is the only reference that never moves.

OS-specific images have no `latest` tag, for the following reasons:

- The version tag already is the moving "newest patched build" tag.
- `latest` would cross OS major versions, such as trixie to forky, without review.
- `latest` is ambiguous when one image has several variants; `ybor/debian` has bullseye, bookworm, and trixie, each full and slim.
- In Kubernetes, an image tagged `latest` with no `imagePullPolicy` defaults to `Always`, so every pod start depends on the registry.

A few images (such as `aws-cli` and `github-runner`) use `latest` as their `version_tag`; there it's that image's version tag and moves like any other.

With the default `IfNotPresent` pull policy, a Kubernetes node keeps whichever build of a moving tag it pulled first, so weekly patches reach new nodes, not running ones. Pin a dated tag or digest when you need a known build.

## DevOps

### Upstream images come through Artifactory

Every `FROM` that names a public upstream image pulls it through `p6m.jfrog.io/p6m-dev-docker-remote/`, the Artifactory remote for Docker Hub, using the workflow's Artifactory login. Pulling straight from a public registry from GitHub runners hits anonymous rate limits (`toomanyrequests` from `public.ecr.aws`), which fails `base` legs and skips every job that needs them. Use the same prefix when adding an image: `p6m.jfrog.io/p6m-dev-docker-remote/library/<name>:<tag>` for Docker official images.

### Automated Security Patches

- The GitHub Workflow Runs on a Weekly schedule
- The Base Container(s) run upgrades (e.g. `apt-get upgrade`) to install security patches
- The Base Container(s) create sums of all installed packages
  - If the sum changes, all dependent containers will implicitly rebuild
  - This uses Docker Multi-stage to determine the package sums

#### Manual Security Patches

- Simply [run the `workflow_dispatch`](.github/workflows/build-push.yml) trigger
  - There is a `CACHE_BUST` which uses `${{ github.run_id }}` which will force a re-check of package sums post-upgrade in the `pkgsum` build stage

## Repository Structure

For visual ordering only, the following folder structure is used:

- `0-*`: [OS-Specific Images](#base-images)
- `1-*`: [Language-Specific Images](#language-specific-images)
- `2-*`: [Application-Specific Images](#application-specific-images)

The actual order is defined in the [Github Workflow](.github/workflows/build-push.yml).

### OS-Specific Images

Folders prefixed with `0-` are base containers, such as Debian

- Subfolders within are based on the OS-variant
- The label for base containers shall be defined using the Docker Metadata action

### Language-Specific Images

Folders prefixed with `1-` are language-specific containers, such as Node and Python

- They are built using of a specific [OS-Specific Image](#os-specific-images)
  - The [Github Workflow](.github/workflows/build-push.yml) ensures that these images are built _after_ an OS-Specific Image
- Subfolders within are based on the Language version

### Application-Specific Images

Folders prefixed with `2-` are app-specific containers, such as Node, Python or Postgres, etc.

- Subfolders (_recommended structure_):
  - First level: Application Version `{APPNAME}{MAJOR}.{MINOR}` (e.g. `fastapi0.68`)
  - Second level (if necessary): Language Version (e.g. `python3.9`)
- Each language version is targeted at a specific Language-Specific Image, or OS-Specific Image
