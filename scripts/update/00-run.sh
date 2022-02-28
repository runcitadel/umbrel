#!/usr/bin/env bash
set -euo pipefail

RELEASE=$1
UMBREL_ROOT=$2

# Check if $UMBREL_ROOT/.umbrel-$RELEASE exists, if it does, rename it to $UMBREL_ROOT/.citadel-$RELEASE
if [ -d "$UMBREL_ROOT/.umbrel-$RELEASE" ]; then
    mv "$UMBREL_ROOT/.umbrel-$RELEASE" "$UMBREL_ROOT/.citadel-$RELEASE"
fi

echo
echo "======================================="
echo "=============== UPDATE ================"
echo "======================================="
echo "========= Stage: Pre-update ==========="
echo "======================================="
echo

# Stop karen early
pkill -f "\./karen" || true

# Make sure any previous backup doesn't exist
if [[ -d "$UMBREL_ROOT"/.citadel-backup ]]; then
    echo "Cannot install update. A previous backup already exists at $UMBREL_ROOT/.citadel-backup"
    echo "This can only happen if the previous update installation wasn't successful"
    exit 1
fi

echo "Installing Citadel $RELEASE at $UMBREL_ROOT"

# Update status file
cat <<EOF > "$UMBREL_ROOT"/statuses/update-status.json
{"state": "installing", "progress": 20, "description": "Backing up", "updateTo": "$RELEASE"}
EOF

# Fix permissions
echo "Fixing permissions"
find "$UMBREL_ROOT" -path "$UMBREL_ROOT/app-data" -prune -o -exec chown 1000:1000 {} +

# Backup
echo "Backing up existing directory tree"

rsync -av \
    --include-from="$UMBREL_ROOT/.citadel-$RELEASE/scripts/update/.updateinclude" \
    --exclude-from="$UMBREL_ROOT/.citadel-$RELEASE/scripts/update/.updateignore" \
    "$UMBREL_ROOT"/ \
    "$UMBREL_ROOT"/.citadel-backup/

echo "Successfully backed up to $UMBREL_ROOT/.citadel-backup"
