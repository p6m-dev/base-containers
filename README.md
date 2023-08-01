# Base Containers

This repository contains Docker Images that are automatically patched but with latest and predictable versions of applications installed.

These images are published to [DockerHub](https://hub.docker.com) under the namespace set using the `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN_RW` GitHub Secrets.

See the [Github Workflow](.github/workflows/build-push.yml) for specifics on each type of container built.

## DevOps

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
