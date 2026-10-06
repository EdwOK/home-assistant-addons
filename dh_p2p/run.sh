#!/usr/bin/env bash
# Runs one patched dh-p2p relay session that forwards all VTO ports, and
# restarts it whenever it exits (it exits on handshake timeout or when the
# device stops answering).
set -u

OPTS=/data/options.json
SERIAL=$(jq -r '.serial' "$OPTS")
BIND=$(jq -r '.bind_address' "$OPTS")
HTTP_PORT=$(jq -r '.http_port' "$OPTS")
RTSP_PORT=$(jq -r '.rtsp_port' "$OPTS")
DEBUG=$(jq -r '.debug_log' "$OPTS")

log() { echo "[$(date '+%H:%M:%S')] $*"; }

if [ -z "$SERIAL" ]; then
  log "Set 'serial' in the add-on configuration."
  exit 1
fi

# Without debug_log only dh-p2p's own status lines are shown, not every packet.
filter() {
  if [ "$DEBUG" = true ]; then
    cat
  else
    grep --line-buffered -E \
      'session established|Forwarding|Accepted|did not accept|timed out|session lost|PTCP (duplicate|gap|resync)|panicked|Error'
  fi
}

while true; do
  # The Dahua integration always connects to port 5000 for VTO events.
  log "Connecting to $SERIAL (http $BIND:$HTTP_PORT, rtsp $BIND:$RTSP_PORT, events $BIND:5000)"
  dh-p2p -r \
    -p "$BIND:$HTTP_PORT:80" \
    -p "$BIND:$RTSP_PORT:554" \
    -p "$BIND:5000:5000" \
    "$SERIAL" 2>&1 | filter
  log "dh-p2p exited (code ${PIPESTATUS[0]}), reconnecting in 10s"
  sleep 10
done
