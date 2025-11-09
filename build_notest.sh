#!/usr/bin/env bash
set -euo pipefail

# Projektverzeichnis bestimmen (da, wo das Skript liegt)
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${PROJECT_ROOT}/build"

IMAGE_BASENAME="raku-sles15sp6"
VERSION="${1:-dev}"   # Version kommt als 1. Parameter: ./build.sh 1.0.0
IMAGE_NAME="${IMAGE_BASENAME}:${VERSION}"
TAR_NAME="${IMAGE_BASENAME}-${VERSION}.tar"

echo "==> Project root: ${PROJECT_ROOT}"
echo "==> Build dir:    ${BUILD_DIR}"
echo "==> Image name:   ${IMAGE_NAME}"
echo "==> Tarball:      ${TAR_NAME}"
echo

mkdir -p "${BUILD_DIR}"

echo "==> Building x86_64 image with Podman..."
podman build --arch amd64 -t "${IMAGE_NAME}" -f "${PROJECT_ROOT}/Containerfile" "${PROJECT_ROOT}"

echo "==> Test run (raku -v)..."
podman run --rm "${IMAGE_NAME}" raku -v

echo "==> Saving image to ${BUILD_DIR}/${TAR_NAME}..."
podman save -o "${BUILD_DIR}/${TAR_NAME}" "${IMAGE_NAME}"

echo
echo "==> Done."
echo "   Image:   ${IMAGE_NAME}"
echo "   Tarball: ${BUILD_DIR}/${TAR_NAME}"
echo
echo "Kopiere das Tarball auf deinen SLES-Server und lade es dort mit:"
echo "  podman load -i ${TAR_NAME}"
echo "  podman run -it ${IMAGE_NAME} raku -v"
