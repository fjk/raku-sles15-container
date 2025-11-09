# Raku SLES15 Runtime Builder

This project builds a portable **Raku runtime** (Rakudo + Zef) for **SUSE Linux Enterprise 15 (SLES)**  
using **Podman** on macOS.  
It can produce both:

- a **container image** (for development & testing on macOS)  
- a **runtime tarball** (`raku-runtime-<version>.tar.gz`) for xcopy-style deployment on SLES (no root, no Podman)

---

## 🧱 Requirements (on macOS build machine)

- Podman (≥ 4.x, preferably 5.x)
- Bash, Git, curl, tar, gzip
- GitHub CLI (`gh`) authenticated (`gh auth login`)

---

## 🚀 Build a new version

To build only (no GitHub release):

```bash
./build.sh 0.0.1
