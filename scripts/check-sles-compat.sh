#!/usr/bin/env bash
# Simple compatibility/info check for the Raku SLES15 runtime container
# Runs inside the container and prints OS / kernel / glibc / repo info.

set -e

echo "============================================================"
echo " SLES15 / openSUSE Leap Compatibility Check"
echo "============================================================"
echo

echo "=== OS Release (/etc/os-release) ==="
if [ -f /etc/os-release ]; then
  cat /etc/os-release
else
  echo "No /etc/os-release found."
fi
echo

echo "=== Kernel (uname -r) ==="
uname -r || echo "uname -r failed"
echo

echo "=== glibc version (ldd --version) ==="
if command -v ldd >/dev/null 2>&1; then
  ldd --version | head -n 1
else
  echo "ldd not found."
fi
echo

echo "=== SUSE repositories (zypper lr -d) ==="
if command -v zypper >/dev/null 2>&1; then
  zypper lr -d || echo "zypper lr -d failed"
else
  echo "zypper not found."
fi
echo

echo "=== Core SUSE RPMs (libzypp, suse-release*) ==="
if command -v rpm >/dev/null 2>&1; then
  rpm -q libzypp || echo "libzypp not installed"
  rpm -qa | grep -E '^suse-release|^openSUSE-release' || echo "no suse-release/openSUSE-release package found"
else
  echo "rpm not found."
fi
echo

echo "============================================================"
echo " End of compatibility report"
echo "============================================================"