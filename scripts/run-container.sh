#!/usr/bin/env bash
set -euo pipefail

docker run --rm -it \
  --name rvqemu \
  -v "$(pwd)":/home/rvqemu-dev/workspace \
  -w /home/rvqemu-dev/workspace \
  -p 1234:1234 \
  rvqemu /bin/bash