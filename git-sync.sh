#!/usr/bin/env bash
#
# git-sync.sh
#
# Push the current branch to both GitHub (origin) and GitLab (gitlab),
# including tags (optional, see below).

set -euo pipefail

# Detect current branch
branch="$(git rev-parse --abbrev-ref HEAD)"

echo "Current branch: ${branch}"
echo

# Push to GitHub
echo "→ Pushing to origin (GitHub)..."
git push origin "${branch}"

# Push to GitLab
echo
echo "→ Pushing to gitlab (GitLab)..."
git push gitlab "${branch}"

# Optional: also sync tags
if [ "${1-}" = "--tags" ]; then
  echo
  echo "→ Also pushing tags to origin and gitlab..."
  git push origin --tags
  git push gitlab --tags
fi

echo
echo "✅ Sync complete."
EOF

chmod +x git-sync.sh