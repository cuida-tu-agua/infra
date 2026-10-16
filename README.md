# infra

Runs the whole Cuida Tu Agua system with Docker Compose — the same definition locally and in production.

## Layout (next to the other repos)
cuida-tu-agua/ → infra/, sy-water-backend/, sy-water-db/, sy-water-frontend/

## Local
```powershell
Copy-Item .env.example .env            # fill the passwords
docker compose up -d sqlserver redis rabbitmq mosquitto mailpit
docker compose --profile migrate up -d migrate
docker compose up -d --build
```
Web http://localhost:8082 · Gateway http://localhost:8080 · Mailpit http://localhost:8025 · RabbitMQ http://localhost:15672

## Production
`.env` with `COMPOSE_FILE=compose.yml:compose.prod.yml` (see the deployment guide).

## Files
| File | Use |
|---|---|
| compose.yml | Base: all containers + migrations (profile `migrate`) |
| compose.override.yml | Local (loaded automatically): ports on localhost, Mailpit |
| compose.prod.yml | Production: Caddy, SQL Server Express, memory limits |
