#!/usr/bin/env bash
# Clones (or updates) every repo with the delivered branch, using the same layout as the dev PCs.
set -euo pipefail
cd "$(dirname "$0")/../.."          # the folder that contains infra/

clone() {  # repo  branch  folder
  if [ -d "$3/.git" ]; then git -C "$3" pull --ff-only
  else git clone -b "$2" "https://github.com/cuida-tu-agua/$1.git" "$3"; fi
}

mkdir -p sy-water-backend sy-water-db sy-water-frontend
clone iam-backend         dev  sy-water-backend/ms-iam
clone ms-places           dev  sy-water-backend/ms-places
clone ms-device           dev  sy-water-backend/ms-devices
clone ms-consumption      dev  sy-water-backend/ms-consumption
clone ms-valve            dev  sy-water-backend/ms-valve
clone ms-notification     dev  sy-water-backend/ms-notifications
clone api-gateway         dev  sy-water-backend/api-gateway
clone ms-iam-db           main sy-water-db/ms-iam-db
clone ms-places-db        main sy-water-db/ms-places-db
clone ms-device-db        dev  sy-water-db/ms-device-db
clone ms-consumption-db   dev  sy-water-db/ms-consumption-db
clone ms-valve-db         dev  sy-water-db/ms-valve-db
clone ms-notification-db  dev  sy-water-db/ms-notification-db
clone cuida-tu-agua-frontNEW feauture-one-proyect sy-water-frontend/save-your-water
