#!/usr/bin/env bash
# Boot the OWASP Juice Shop server. Safe to run more than once.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=repo.sh
source "$SCRIPT_DIR/repo.sh"
PRIMARY_REPO="$(cursor_primary_repo)"
SHOP="$(cursor_find_repo securing-your-code package.json "$PRIMARY_REPO")"

cd "$SHOP"
mkdir -p frontend/dist/frontend/assets/public/videos ftp

if curl -sf --max-time 2 -o /dev/null http://127.0.0.1:3000/rest/admin/application-version; then
  echo "Juice Shop is already listening on port 3000"
  exit 0
fi

exec npm start
