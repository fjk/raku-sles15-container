#!/usr/bin/env bash
#===============================================================================
#  build.sh
#
#  Purpose:
#    Build a portable Raku runtime and container image for SLES 15 targets.
#    - Runs locally on macOS using Podman (x86_64 emulation).
#    - Produces:
#        1. a container image (for development/debug use)
#        2. a standalone runtime tarball for SLES ($HOME/bin install)
#
#  Usage:
#    ./build.sh [version]
#    Example: ./build.sh 1.0.0
#
#  Output files (in ./build):
#    - raku-sles15sp6-<version>.tar      (Podman image)
#    - raku-runtime-<version>.tar.gz     (portable Raku runtime)
#===============================================================================

set -euo pipefail

#------------------------------------------------------------------------------
# Define project structure and variables
#------------------------------------------------------------------------------
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${PROJECT_ROOT}/build"

IMAGE_BASENAME="raku-sles15sp6"
VERSION="${1:-dev}"   # Default version if none provided
IMAGE_NAME="${IMAGE_BASENAME}:${VERSION}"
IMAGE_TAR_NAME="${IMAGE_BASENAME}-${VERSION}.tar"
RUNTIME_TAR_NAME="raku-runtime-${VERSION}.tar.gz"

echo "==> Project root: ${PROJECT_ROOT}"
echo "==> Build dir:    ${BUILD_DIR}"
echo "==> Image name:   ${IMAGE_NAME}"
echo "==> Image tar:    ${IMAGE_TAR_NAME}"
echo "==> Runtime tar:  ${RUNTIME_TAR_NAME}"
echo

mkdir -p "${BUILD_DIR}"

#------------------------------------------------------------------------------
# STEP 1 - Build the container image
#------------------------------------------------------------------------------
echo "==> Building image (architecture: x86_64)..."
podman build --arch amd64 -t "${IMAGE_NAME}" -f "${PROJECT_ROOT}/Containerfile" "${PROJECT_ROOT}"

#------------------------------------------------------------------------------
# STEP 2 - Run a test inside the built image
#------------------------------------------------------------------------------
echo
echo "==> Testing Raku installation inside the image..."
echo "--------------------------------------------------"
podman run --rm "${IMAGE_NAME}" raku -v
echo "--------------------------------------------------"
echo "==> Test OK."
echo

#------------------------------------------------------------------------------
# STEP 3 - Save the Podman image as a tarball
#------------------------------------------------------------------------------
echo "==> Saving image to ${BUILD_DIR}/${IMAGE_TAR_NAME}..."
podman save -o "${BUILD_DIR}/${IMAGE_TAR_NAME}" "${IMAGE_NAME}"

#------------------------------------------------------------------------------
# STEP 4 - Extract only the current Raku runtime from inside the container
#------------------------------------------------------------------------------
echo
# Explanation:
#   - Inside the container, rakubrew manages versions under /root/.rakubrew/versions/
#   - We detect the current active version, and export only that directory.
#   - The tarball will contain "moar-<version>" as top-level folder.
echo "==> Extracting portable Raku runtime..."
podman run --rm "${IMAGE_NAME}" sh -lc '
  set -e
  cd /root/.rakubrew
  # Example output of `rakubrew current`:
  #   "Currently running moar-2025.10"
  # We only want the last field: "moar-2025.10"
  current_line=$(/root/.rakubrew/bin/rakubrew current)
  current=$(echo "$current_line" | awk "{print \$NF}")
  echo "Detected active Raku version directory: $current" >&2
  cd versions
  tar czf - "$current"
' > "${BUILD_DIR}/${RUNTIME_TAR_NAME}"

echo
echo "==> Done."
echo "   Image:           ${IMAGE_NAME}"
echo "   Image tarball:   ${BUILD_DIR}/${IMAGE_TAR_NAME}"
echo "   Runtime tarball: ${BUILD_DIR}/${RUNTIME_TAR_NAME}"
echo
echo "Usage on SLES target:"
echo "  1. Copy ${RUNTIME_TAR_NAME} to the target user's home directory."
echo "  2. Unpack it and link 'raku' into ~/bin:"
echo
echo "     mkdir -p ~/raku-${VERSION}"
echo "     tar xzf ${RUNTIME_TAR_NAME} -C ~/raku-${VERSION} --strip-components=1"
echo "     mkdir -p ~/bin"
echo "     ln -sf ~/raku-${VERSION}/bin/raku ~/bin/raku"
echo "     echo 'export PATH=\"\$HOME/bin:\$PATH\"' >> ~/.bashrc"
echo "     source ~/.bashrc"
echo
echo "  3. Test on SLES:"
echo "     raku -v"
echo
echo "To build a new Raku version later, simply rerun:"
echo "     ./build.sh 1.1.0"
echo
#===============================================================================