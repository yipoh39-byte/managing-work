#!/usr/bin/env bash
# Idempotent Cloud Agent install for managing-work and the sibling Juice Shop app.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=repo.sh
source "$SCRIPT_DIR/repo.sh"
PRIMARY_REPO="$(cursor_primary_repo)"

if ! dpkg -s libxml2-dev >/dev/null 2>&1 || ! command -v jq >/dev/null 2>&1; then
  sudo apt-get update
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    build-essential python3 pkg-config libxml2-dev jq ca-certificates curl
fi

jq -e 'type == "array" and length > 0' "$PRIMARY_REPO/.github/scripts/issue-seeds.json" >/dev/null
bash -n "$PRIMARY_REPO/.github/scripts/prepare-lab-env.sh"

SHOP="$(cursor_find_repo securing-your-code package.json "$PRIMARY_REPO")"
cd "$SHOP"

# This checkout omits a few Juice Shop v17.1.0 runtime files. Fetch them only
# when they are absent so a fresh clone can boot, and leave committed copies alone.
JUICE_RAW="https://raw.githubusercontent.com/juice-shop/juice-shop/v17.1.0"
fetch_if_missing() {
  local rel="$1"
  if [[ -f "$rel" ]]; then
    return 0
  fi
  mkdir -p "$(dirname "$rel")"
  curl -fsSL "$JUICE_RAW/$rel" -o "$rel"
}

fetch_if_missing config.schema.yml
fetch_if_missing ctf.key
fetch_if_missing .well-known/security.txt
fetch_if_missing .well-known/csaf/index.txt
fetch_if_missing .well-known/csaf/changes.csv
fetch_if_missing .well-known/csaf/provider-metadata.json
fetch_if_missing .well-known/csaf/2017/juice-shop-sa-20200513-express-jwt.json
fetch_if_missing .well-known/csaf/2017/juice-shop-sa-20200513-express-jwt.json.asc
fetch_if_missing .well-known/csaf/2017/juice-shop-sa-20200513-express-jwt.json.sha512
fetch_if_missing .well-known/csaf/2021/juice-shop-sa-20211014-proto.json
fetch_if_missing .well-known/csaf/2021/juice-shop-sa-20211014-proto.json.asc
fetch_if_missing .well-known/csaf/2021/juice-shop-sa-20211014-proto.json.sha512
fetch_if_missing .well-known/csaf/2024/juice-shop-sa-disclaimer.json
fetch_if_missing .well-known/csaf/2024/juice-shop-sa-disclaimer.json.asc
fetch_if_missing .well-known/csaf/2024/juice-shop-sa-disclaimer.json.sha512

export NODE_OPTIONS="${NODE_OPTIONS:---max-old-space-size=4096}"
npm install

# Promo subtitles are copied here on startup. The Angular build does not create
# the directory when the source video is absent.
mkdir -p frontend/dist/frontend/assets/public/videos ftp
