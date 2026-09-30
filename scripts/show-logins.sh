#!/bin/bash
# Print team URLs and player passwords from Terraform state.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TF="$ROOT/terraform"
OUT="$ROOT/out"

if [[ ! -d "$TF/.terraform" ]]; then
  echo "Nothing deployed yet. Run ./scripts/deploy.sh --yes" >&2
  exit 1
fi

mkdir -p "$OUT"
umask 077
terraform -chdir="$TF" output -json teams >"$OUT/teams.json"

python3 - "$OUT/teams.json" "$OUT/logins.txt" <<'PY'
import json
import sys

src, dest = sys.argv[1], sys.argv[2]
teams = json.load(open(src))
lines = []
for name in sorted(teams, key=lambda s: (s.split("_", 1)[0], int(s.split("team", 1)[1].split("-", 1)[0]))):
    row = teams[name]
    lines.append(name)
    lines.append(f"  server  {row['hostname']}")
    lines.append(f"  SSH     {row['ssh']}")
    p1 = row["players"]["player1"]
    p2 = row["players"]["player2"]
    p3 = row["players"]["player3"]
    lines.append(f"  player1 linux    {p1['web']}")
    lines.append(f"           Ubuntu installer password  {p1['password']}")
    lines.append(f"  player2 linux    {p2['web']}")
    lines.append(f"           Ubuntu installer password  {p2['password']}")
    lines.append(f"  player3 windows  {p3['web']}")
    lines.append(f"           RDP {p3['rdp']}  user {p3['user']}  password {p3['password']}")
    lines.append("")
text = "\n".join(lines).rstrip() + "\n"
open(dest, "w").write(text)
sys.stdout.write(text)
PY
chmod 600 "$OUT/teams.json" "$OUT/logins.txt"
echo "Saved to $OUT/logins.txt"
