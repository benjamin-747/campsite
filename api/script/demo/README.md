# build-images-arm64-local.sh

Build and optionally push a **single-architecture** Docker image for the Campsite API.  
The script automatically detects your host CPU and chooses the matching platform (`linux/amd64` or `linux/arm64`).  
A multi-arch manifest is **not** created here – that happens later in the CI workflow.

## Features

* Automatic architecture detection (`uname -m`).
* Supports **build-only** (default) or **build & push** via `--push` flag.
* Adds an architecture suffix (`-amd64` or `-arm64`) to the provided tag.
* Pass-through build arguments for Ruby, Node and Bundler versions.

## Prerequisites

1. **Docker Buildx** enabled:
   ```bash
   docker buildx create --use   # once per machine
   ```
2. If you plan to push (`--push`), log in to the target registry, e.g. ECR Public:
   ```bash
   aws ecr-public get-login-password --region us-east-1 | \
     docker login --username AWS --password-stdin public.ecr.aws
   ```

## Usage

```bash
./script/demo/build-images-arm64-local.sh [IMAGE_TAG] [--push]
```

* `IMAGE_TAG` (optional) – base tag without architecture suffix.  
  Defaults to `campsite-0.1.0-pre-release`.
* `--push` (optional) – push the image to the registry instead of only loading it locally.

### Examples

Build locally for the current architecture:
```bash
./script/demo/build-images-arm64-local.sh
```

Build with a custom tag:
```bash
./script/demo/build-images-arm64-local.sh my-feature-branch
```

Build and push:
```bash
./script/demo/build-images-arm64-local.sh release-1.2.3 --push
```

The resulting image names follow this pattern:
```
public.ecr.aws/m8q5m4u3/mega:<IMAGE_TAG>-<arch>
```
where `<arch>` is `amd64` or `arm64`.

## How It Works

1. Parses CLI flags and determines whether to push.
2. Detects host architecture and sets `--platform` and suffix.
3. Invokes `docker buildx build` with exactly **one** platform, ensuring a single-architecture image.
4. If `--push` is provided, the image is pushed; otherwise it is simply loaded into the local Docker daemon.

## Notes

* This script must be run from the repository root (or adjust the `api` build context path).
* Multi-architecture support is handled in GitHub Actions where the single-arch images are combined into a manifest list.

