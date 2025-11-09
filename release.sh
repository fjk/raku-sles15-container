#!/usr/bin/env bash
#===============================================================================
#  release.sh
#
#  Purpose:
#    Automate a full release cycle:
#      1. Build container image + runtime tarball for a given version
#      2. Create a git tag "v<version>"
#      3. Push main + tag to GitHub
#      4. Create a GitHub Release with the build artifacts attached
#
#  Usage:
#    ./release.sh <version>
#    Example: ./release.sh 0.0.1
#
#  Requirements:
#    - build.sh in the same directory
#    - git repo with "origin" pointing to GitHub
#    - GitHub CLI (gh) installed and authenticated (gh auth login)
#===============================================================================

set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Usage: $0 <version>"
  exit 1
fi

VERSION="$1"
TAG="v${VERSION}"

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${PROJECT_ROOT}/build"
IMAGE_TAR_NAME="raku-sles15sp6-${VERSION}.tar"
RUNTIME_TAR_NAME="raku-runtime-${VERSION}.tar.gz"

cd "${PROJECT_ROOT}"

#------------------------------------------------------------------------------
# Basic checks
#------------------------------------------------------------------------------
if ! command -v gh >/dev/null 2>&1; then
  echo "ERROR: 'gh' (GitHub CLI) not found. Install it and run 'gh auth login' first."
  exit 1
fi

if [ ! -x "./build.sh" ]; then
  echo "ERROR: build.sh not found or not executable in ${PROJECT_ROOT}."
  exit 1
fi

# Optional: warn if git has uncommitted changes
if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "WARNING: You have uncommitted changes."
  echo "It is recommended to commit them before creating a release."
  echo
fi

#------------------------------------------------------------------------------
# STEP 1 - Build artifacts using build.sh
#------------------------------------------------------------------------------
echo "==> Running build.sh for version ${VERSION}..."
./build.sh "${VERSION}"

if [ ! -f "${BUILD_DIR}/${IMAGE_TAR_NAME}" ]; then
  echo "ERROR: Image tarball not found: ${BUILD_DIR}/${IMAGE_TAR_NAME}"
  exit 1
fi
if [ ! -f "${BUILD_DIR}/${RUNTIME_TAR_NAME}" ]; then
  echo "ERROR: Runtime tarball not found: ${BUILD_DIR}/${RUNTIME_TAR_NAME}"
  exit 1
fi

#------------------------------------------------------------------------------
# STEP 2 - Create git tag
#------------------------------------------------------------------------------
if git rev-parse "${TAG}" >/dev/null 2>&1; then
  echo "ERROR: Git tag '${TAG}' already exists. Aborting to avoid overwriting."
  exit 1
fi

echo "==> Creating git tag ${TAG}..."
git tag -a "${TAG}" -m "Release ${TAG}"

#------------------------------------------------------------------------------
# STEP 3 - Push main + tag to origin
#------------------------------------------------------------------------------
echo "==> Pushing 'main' branch and tag ${TAG} to origin..."
git push origin main
git push origin "${TAG}"

#------------------------------------------------------------------------------
# STEP 4 - Create GitHub Release with artifacts
#------------------------------------------------------------------------------
echo "==> Creating GitHub Release ${TAG} with artifacts..."

gh release create "${TAG}" \
  "${BUILD_DIR}/${RUNTIME_TAR_NAME}" \
  "${BUILD_DIR}/${IMAGE_TAR_NAME}" \
  --title "${TAG}" \
  --notes "Raku runtime and container image for SLES15 (version ${VERSION})."

echo
echo "Release ${TAG} created."
echo "Artifacts:"
echo "  - ${BUILD_DIR}/${IMAGE_TAR_NAME}"
echo "  - ${BUILD_DIR}/${RUNTIME_TAR_NAME}"
echo
echo "On SLES you can use the runtime tarball like this:"
echo "  tar xzf ${RUNTIME_TAR_NAME} -C \$HOME/raku-${VERSION} --strip-components=1"
echo "  ln -sf \$HOME/raku-${VERSION}/bin/raku \$HOME/bin/raku"
echo "  raku -v"
#===============================================================================
