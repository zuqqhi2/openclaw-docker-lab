#!/usr/bin/env bash
set -euo pipefail

# Restrict default permissions for newly created files and directories
umask 027

# Use application directories based on HOME
OPENCLAW_HOME="${OPENCLAW_HOME}"
LOG_DIR="${OPENCLAW_HOME}/logs"

# Validate required environment variables
: "${OPENCLAW_GATEWAY_TOKEN:?OPENCLAW_GATEWAY_TOKEN is required}"
: "${DISCORD_BOT_TOKEN:?DISCORD_BOT_TOKEN is required}"
: "${DISCORD_GUILD_ID:?DISCORD_GUILD_ID is required}"
: "${DISCORD_CHANNEL_ID:?DISCORD_CHANNEL_ID is required}"

# Create required directories
mkdir -p "${LOG_DIR}"

# Generate the runtime config from the template
envsubst '${DISCORD_GUILD_ID} ${DISCORD_CHANNEL_ID}' \
  < "${OPENCLAW_HOME}/openclaw.json.template" \
  > "${OPENCLAW_HOME}/.openclaw/openclaw.json"

# Start OpenClaw Gateway and write its log under OPENCLAW_HOME
openclaw gateway --port 18789 --allow-unconfigured --verbose \
  > "${LOG_DIR}/openclaw-gateway.log" 2>&1 &
OPENCLAW_PID=$!

# Stop child process when the container receives a signal
cleanup() {
  kill "${OPENCLAW_PID}" 2>/dev/null || true
}
trap cleanup INT TERM EXIT

sleep 5

# For docker logs command
echo "OpenClaw Gateway: http://127.0.0.1:18789"
echo "Locale:           ${LANG}"

tail -F "${LOG_DIR}/openclaw-gateway.log"