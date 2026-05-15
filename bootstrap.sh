#!/usr/bin/env bash
set -euo pipefail

SECRET_ARN="arn:aws:secretsmanager:eu-north-1:363179374584:secret:strativ-prod-n8n/app-6MOAmq"
APP_DIR="/opt/n8n"
ENV_FILE="${APP_DIR}/.env"

echo "→ Fetching secrets from Secrets Manager..."
SECRET=$(aws secretsmanager get-secret-value \
  --secret-id "${SECRET_ARN}" \
  --query SecretString \
  --output text)

N8N_ENCRYPTION_KEY=$(echo "${SECRET}" | jq -r '.N8N_ENCRYPTION_KEY')
DB_POSTGRESDB_PASSWORD=$(echo "${SECRET}" | jq -r '.DB_POSTGRESDB_PASSWORD')
N8N_BASIC_AUTH_PASSWORD=$(echo "${SECRET}" | jq -r '.N8N_BASIC_AUTH_PASSWORD // empty')

cat > "${ENV_FILE}" <<EOF
N8N_ENCRYPTION_KEY=${N8N_ENCRYPTION_KEY}
DB_POSTGRESDB_PASSWORD=${DB_POSTGRESDB_PASSWORD}
N8N_BASIC_AUTH_PASSWORD=${N8N_BASIC_AUTH_PASSWORD}
EOF

chmod 600 "${ENV_FILE}"
echo "→ .env written to ${ENV_FILE}"

echo "→ Starting stack..."
cd "${APP_DIR}"
docker compose pull
docker compose up -d

echo "✓ n8n is up. Visit https://app.n8n.strativ.se to complete owner setup."
