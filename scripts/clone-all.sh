#!/usr/bin/env bash
# Clones (or updates) every repo with the same layout as the dev PCs.
# Usage: bash scripts/clone-all.sh [branch]   -> dev by default; use "main" on the production server.
# An existing folder is only updated (git pull) on the branch it already has.
set -euo pipefail
cd "$(dirname "$0")/../.."          # the folder that contains infra/
BRANCH="${1:-dev}"
clone() {  # repo  folder
  if [ -d "$2/.git" ]; then git -C "$2" pull --ff-only
  else git clone -b "$BRANCH" "https://github.com/cuida-tu-agua/$1.git" "$2"; fi
}
mkdir -p sy-water-backend sy-water-db sy-water-frontend
clone iam-backend            sy-water-backend/ms-iam
clone ms-places              sy-water-backend/ms-places
clone ms-devices             sy-water-backend/ms-devices
clone ms-consumption         sy-water-backend/ms-consumption
clone ms-valve               sy-water-backend/ms-valve
clone ms-notifications       sy-water-backend/ms-notifications
clone api-gateway            sy-water-backend/api-gateway
clone ms-iam-db              sy-water-db/ms-iam-db
clone ms-places-db           sy-water-db/ms-places-db
clone ms-device-db           sy-water-db/ms-device-db
clone ms-consumption-db      sy-water-db/ms-consumption-db
clone ms-valve-db            sy-water-db/ms-valve-db
clone ms-notification-db     sy-water-db/ms-notification-db
clone cuida-tu-agua-frontNEW sy-water-frontend/save-your-water