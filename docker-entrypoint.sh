#!/bin/bash
set -euo pipefail

# POOL_SIZE=2 mix ecto.setup
# mix deps.compile certifi
# MIX_ENV=prod mix phx.server

#!/bin/sh
set -e

echo "Run: mix phx.swagger.generate to generate swagger docs" 
if [[ "$1" = 'run' ]]; then
      exec /app/bin/papercups start
 else
      exec "$@"
fi

exec "$@"
