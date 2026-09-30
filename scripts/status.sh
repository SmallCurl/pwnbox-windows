#!/bin/bash
# Report whether each team's first web viewer is accepting connections yet.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TF="$ROOT/terraform"

if [[ ! -d "$TF/.terraform" ]]; then
  echo "Nothing deployed yet. Run ./scripts/deploy.sh --yes" >&2
  exit 1
fi

terraform -chdir="$TF" output -json addresses | python3 - <<'PY'
import json
import socket
import sys

addresses = json.load(sys.stdin)

def sort_key(name):
    kind, rest = name.split("_", 1)
    number = int(rest.split("team", 1)[1].split("-", 1)[0])
    return (kind, number)

def open_port(ip, port):
    sock = socket.socket()
    sock.settimeout(3)
    try:
        sock.connect((ip, port))
    except OSError:
        return False
    else:
        return True
    finally:
        sock.close()

for name in sorted(addresses, key=sort_key):
    ip = addresses[name]
    if open_port(ip, 8006):
        print(f"{name}  {ip}  viewers up")
    else:
        print(f"{name}  {ip}  booting")
PY
