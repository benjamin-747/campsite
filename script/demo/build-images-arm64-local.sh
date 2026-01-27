#!/usr/bin/env bash
# Build a single-architecture Docker image for Campsite locally.
# The script auto-detects host CPU (arm64 vs amd64) and builds the matching
# architecture image. Multi-arch manifest is created later in CI.
#
# Usage:
#   ./script/demo/build-images-arm64-local.sh [IMAGE_TAG] [--push]
#     --push  Also push to remote registry; if omitted, image is only built and loaded locally.
#
# Requirements:
#   - Docker with buildx enabled ("docker buildx create --use")
#   - If using --push you must already be logged into the destination registry.

set -euo pipefail

REGISTRY_ALIAS="m8q5m4u3"               # Public ECR alias
REGISTRY="public.ecr.aws/${REGISTRY_ALIAS}"
REPOSITORY="mega"

# ----------------------------------------
# Parse CLI arguments
# ----------------------------------------
DO_PUSH=false
POSITIONAL=()
for arg in "$@"; do
  case "$arg" in
    --push)
      DO_PUSH=true
      ;;
    *)
      POSITIONAL+=("$arg")
      ;;
  esac
done
set -- "${POSITIONAL[@]}"

# Image tag via first positional arg, or env, or default
IMAGE_TAG_BASE="${IMAGE_TAG:-${1:-campsite-0.1.0-pre-release}}"

# Detect host architecture and map to Docker platform / suffix
ARCH_NATIVE="$(uname -m)"
case "$ARCH_NATIVE" in
  arm64|aarch64)
    PLATFORM="linux/arm64"
    ARCH_SUFFIX="arm64"
    ;;
  x86_64|amd64)
    PLATFORM="linux/amd64"
    ARCH_SUFFIX="amd64"
    ;;
  *)
    echo "Unsupported architecture: $ARCH_NATIVE" >&2
    exit 1
    ;;
esac

# Build-time args (override via env vars if needed)
RUBY_VERSION="${RUBY_VERSION:-3.3.4}"
NODE_VERSION="${NODE_VERSION:-18.16.1}"
BUNDLER_VERSION="${BUNDLER_VERSION:-2.3.14}"

IMAGE_TAG="${IMAGE_TAG_BASE}-${ARCH_SUFFIX}"
IMAGE_NAME="${REGISTRY}/${REPOSITORY}:${IMAGE_TAG}"

echo "Building ${IMAGE_NAME} (${PLATFORM}) …"

# Ensure buildx is available
if ! docker buildx version >/dev/null 2>&1; then
  echo "docker buildx not available; please install Docker 19.03+ and enable buildx." >&2
  exit 1
fi

# Build image (always --load to ensure single-arch manifest)
if ! docker buildx build \
  --platform "$PLATFORM" \
  --load \
  -t "$IMAGE_NAME" \
  api \
  --build-arg RUBY_VERSION="$RUBY_VERSION" \
  --build-arg NODE_VERSION="$NODE_VERSION" \
  --build-arg BUNDLER_VERSION="$BUNDLER_VERSION"; then
  echo "docker buildx build failed" >&2
  exit 1
fi

echo "Image built and loaded locally: $IMAGE_NAME"

# Optionally push to registry
if $DO_PUSH; then
  echo "Pushing $IMAGE_NAME to registry …"
  if ! docker push "$IMAGE_NAME"; then
    echo "docker push failed" >&2
    exit 1
  fi
  echo "Image pushed successfully: $IMAGE_NAME"
else
  echo "Push flag not set; skipping docker push."
fi
