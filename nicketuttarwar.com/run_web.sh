#!/usr/bin/env bash
# Launch the static site on a random port and open it in the default browser.

set -e
cd "$(dirname "$0")"

# Random port between 8080 and 19999 (avoids privileged and common ports)
if [ -n "$BASH_VERSION" ]; then
  PORT=$((8080 + RANDOM % 11920))
else
  PORT=$((8080 + $(od -An -N2 -i /dev/urandom | tr -d ' ') % 11920))
fi

URL="http://127.0.0.1:${PORT}"

echo "Starting server on port ${PORT}..."
echo "URL: ${URL}"
echo "Press Ctrl+C to stop."
echo ""

# Open default browser (macOS: open, Linux: xdg-open)
if command -v open >/dev/null 2>&1; then
  (sleep 1 && open "$URL") &
elif command -v xdg-open >/dev/null 2>&1; then
  (sleep 1 && xdg-open "$URL") &
fi

exec python3 -m http.server "$PORT"
