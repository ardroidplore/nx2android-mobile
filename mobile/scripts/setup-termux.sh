#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
ROOT="/storage/emulated/0/nx2android-mobile"
if [ ! -f "$ROOT/porter/cli.py" ]; then
  echo "Repository not found at $ROOT. Extract the fork there first." >&2
  exit 1
fi
pkg update -y
pkg install -y proot-distro git
termux-setup-storage || true
proot-distro install ubuntu || true
proot-distro login ubuntu --bind /storage/emulated/0:/storage/shared -- bash /storage/shared/nx2android-mobile/mobile/scripts/setup-ubuntu.sh
