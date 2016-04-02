#!/usr/bin/env bash
BROKER_URL=${BROKER_URL:-http://127.0.0.1/conn}
LINK_NAME=${LINK_NAME:-DQL}
LOG_LEVEL=${LOG_LEVEL:-info}

exec dart /app/bin/run.dart \
    --broker "${BROKER_URL}" \
    --name "${LINK_NAME}" \
    --log "${LOG_LEVEL}"
