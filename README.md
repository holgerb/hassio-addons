# Home Assistant add-on: holgerb

[![Open your Home Assistant instance and show the add add-on repository dialog with a specific repository URL pre-filled.](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2Fholgerb%2Fhassio-addons)
## Add-ons

This repository contains the following add-ons

### [Teddy Cloud](./teddy_cloud)

![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]

_Run teddy cloud on your home assistant instance._

## Building and publishing

The Dockerfiles use the multi-platform Home Assistant Alpine base image and can
be built directly with Docker BuildKit:

```sh
docker build -t teddy-cloud:local ./teddy_cloud
docker build -t teddy-cloud-edge:local ./teddy_cloud_edge
```

The Builder workflow validates both add-ons on native AMD64 and ARM64 GitHub
runners for pull requests and manual runs. Only pushes to `main` publish images
to GHCR and sign them with Cosign using GitHub OIDC. Builds use separate caches
for each add-on and architecture.

Each successful add-on build publishes architecture-specific images, then a
signed multi-platform manifest at `ghcr.io/holgerb/teddy_cloud` or
`ghcr.io/holgerb/teddy_cloud_edge`. Tags include the commit SHA, the version from
the add-on's `config.yaml`, and `latest`. Manifests use the commit SHA to select
matching architecture images and are published only after both builds succeed.
Home Assistant resolves the architecture through the manifest; existing
architecture-specific image names are also retained by the build workflow.

The first publish creates the new generic GHCR packages. Ensure those packages
are public so Home Assistant installations can pull them without authentication.

The workflow follows Home Assistant's
[BuildKit migration guide](https://contributors.home-assistant.io/blog/2026/04/02/builder-migration/).

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
