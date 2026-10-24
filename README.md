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

SMS / WhatsApp (HU-028): locally they are mails in Mailpit (to `sms.<number>@sms.cuidatuagua.local` or `whatsapp.<number>@…`), no account needed. To send to a real phone put `SMS_PROVIDER=twilio` and the `TWILIO_*` values in `.env` (see `.env.example`). With Twilio, leave `TWILIO_SMS_FROM` empty for WhatsApp only and put the approved templates in `TWILIO_WHATSAPP_TEMPLATE_SID` / `TWILIO_CODE_TEMPLATE_SID`. WhatsApp can go by the WhatsApp Cloud API of Meta instead (free test number): `WHATSAPP_PROVIDER=meta` + `META_ACCESS_TOKEN` and `META_PHONE_NUMBER_ID`; SMS keeps going by `SMS_PROVIDER`.

## Production
`.env` with `COMPOSE_FILE=compose.yml:compose.prod.yml` (see the deployment guide).

## Files
| File | Use |
|---|---|
| compose.yml | Base: all containers + migrations (profile `migrate`) |
| compose.override.yml | Local (loaded automatically): ports on localhost, Mailpit (also for the SMS / WhatsApp) |
| compose.prod.yml | Production: Caddy, SQL Server Express, memory limits |
