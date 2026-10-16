#!/usr/bin/env bash
# Full backup of sy-water-db into infra/backups (keeps the last 7).
set -euo pipefail
cd "$(dirname "$0")/.."
set -a; source .env; set +a
mkdir -p backups
NAME="sy-water-db-$(date +%Y%m%d-%H%M).bak"
docker compose exec -T sqlserver /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -C -b \
  -Q "BACKUP DATABASE [sy-water-db] TO DISK = N'/var/opt/mssql/$NAME' WITH INIT"
docker compose cp "sqlserver:/var/opt/mssql/$NAME" "backups/$NAME"
docker compose exec -T sqlserver rm -f "/var/opt/mssql/$NAME"
ls -1t backups/*.bak | tail -n +8 | xargs -r rm --
echo "Backup: backups/$NAME"
