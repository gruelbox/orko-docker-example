#!/bin/bash
set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

echo "### Starting no-ip ..."
set +e
docker stop noip-temp-setup
set -e
docker pull -q coppit/no-ip
docker run -d --rm \
  --name noip-temp-setup \
  -v "/etc/localtime:/etc/localtime" \
  -v "$DIR/data/noip:/config" \
  coppit/no-ip
echo "### Waiting to ensure we've updated the IP ..."
sleep 30s
echo "### Shutting down noip"
docker stop noip-temp-setup