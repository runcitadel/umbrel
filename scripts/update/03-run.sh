#!/usr/bin/env bash
set -euo pipefail

RELEASE=$1
UMBREL_ROOT=$2

./check-memory "${RELEASE}" "${UMBREL_ROOT}" "notfirstrun"

echo
echo "======================================="
echo "=============== UPDATE ================"
echo "======================================="
echo "=========== Stage: Success ============"
echo "======================================="
echo

# Cleanup
echo "Removing backup"
cat <<EOF > "$UMBREL_ROOT"/statuses/update-status.json
{"state": "installing", "progress": 95, "description": "Removing backup"}
EOF
[[ -d "$UMBREL_ROOT"/.umbrel-backup ]] && rm -rf "$UMBREL_ROOT"/.umbrel-backup
[[ -d "$UMBREL_ROOT"/.citadel-backup ]] && rm -rf "$UMBREL_ROOT"/.citadel-backup

echo "Successfully prepared for Citadel migration"
cat <<EOF > "$UMBREL_ROOT"/statuses/update-status.json
{"state": "installing", "progress": 99, "description": "You can now shut down your Raspberry Pi ('sudo shutdown now' via SSH) and flash Citadel.", "updateTo": ""}
EOF
