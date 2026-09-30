#!/bin/bash
# Create the student and work team servers.
# Each server runs 2 Linux Dockur desktops and 1 Windows Dockur desktop.
# Usage: ./scripts/deploy.sh [--yes]
# Example: STUD_COUNT=1 WORK_COUNT=1 ./scripts/deploy.sh --yes
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TF="$ROOT/terraform"
OUT="$ROOT/out"
YES="${1:-}"

if [[ "$YES" == "-h" || "$YES" == "--help" ]]; then
  YES=""
fi

if [[ -n "$YES" && "$YES" != "--yes" ]]; then
  echo "Usage: $0 [--yes]" >&2
  echo "Defaults: 10 student teams (stud_team1-pwnbox .. stud_team10-pwnbox)" >&2
  echo "          12 work teams    (work_team1-pwnbox .. work_team12-pwnbox)" >&2
  echo "Override with STUD_COUNT and WORK_COUNT." >&2
  echo "Env: HCLOUD_TOKEN LOCATION SERVER_TYPE LINUX_BOOT WINDOWS_VERSION SSH_PUBLIC_KEY_FILE" >&2
  exit 1
fi

if [[ -z "${HCLOUD_TOKEN:-}" ]]; then
  echo "Set HCLOUD_TOKEN to a Hetzner Read & Write API token." >&2
  exit 1
fi

STUD_COUNT="${STUD_COUNT:-10}"
WORK_COUNT="${WORK_COUNT:-12}"
LOCATION="${LOCATION:-fsn1}"
SERVER_TYPE="${SERVER_TYPE:-cx52}"
LINUX_BOOT="${LINUX_BOOT:-ubuntu}"
WINDOWS_VERSION="${WINDOWS_VERSION:-11}"
SSH_PUBLIC_KEY_FILE="${SSH_PUBLIC_KEY_FILE:-$HOME/.ssh/id_ed25519.pub}"

if ! [[ "$STUD_COUNT" =~ ^[0-9]+$ && "$WORK_COUNT" =~ ^[0-9]+$ ]]; then
  echo "STUD_COUNT and WORK_COUNT must be numbers." >&2
  exit 1
fi

if [[ ! -f "$SSH_PUBLIC_KEY_FILE" && -f "$HOME/.ssh/id_rsa.pub" ]]; then
  SSH_PUBLIC_KEY_FILE="$HOME/.ssh/id_rsa.pub"
fi
if [[ ! -f "$SSH_PUBLIC_KEY_FILE" ]]; then
  echo "SSH public key not found: $SSH_PUBLIC_KEY_FILE" >&2
  echo "Set SSH_PUBLIC_KEY_FILE to a .pub file." >&2
  exit 1
fi

PUB="$(tr -d '\n' <"$SSH_PUBLIC_KEY_FILE")"
mkdir -p "$OUT"
umask 077

cat >"$TF/terraform.tfvars" <<EOF
ssh_public_key  = "${PUB}"
stud_count      = ${STUD_COUNT}
work_count      = ${WORK_COUNT}
location        = "${LOCATION}"
server_type     = "${SERVER_TYPE}"
linux_boot      = "${LINUX_BOOT}"
windows_version = "${WINDOWS_VERSION}"
EOF
chmod 600 "$TF/terraform.tfvars"

terraform -chdir="$TF" init -input=false
terraform -chdir="$TF" plan -input=false -out="$OUT/plan.tfplan"

if [[ "$YES" != "--yes" ]]; then
  echo
  echo "Plan only. Re-run with --yes to create ${STUD_COUNT} student and ${WORK_COUNT} work servers."
  exit 0
fi

terraform -chdir="$TF" apply -input=false "$OUT/plan.tfplan"
rm -f "$OUT/plan.tfplan"
"$ROOT/scripts/show-logins.sh"

echo
echo "Servers are up. Each one still has to download Ubuntu twice and Windows once."
echo "Check viewers with ./scripts/status.sh"
