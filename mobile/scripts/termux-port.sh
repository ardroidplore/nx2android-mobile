#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
REPO="/storage/emulated/0/nx2android-mobile"
GAME_DIR="${1:-}"
KEYS_FILE="${2:-}"
OUT_DIR="${3:-/storage/emulated/0/nx2android-output}"
if [ -z "$GAME_DIR" ] || [ -z "$KEYS_FILE" ]; then
  echo "Usage: termux-port.sh GAME_FOLDER PROD_KEYS [OUTPUT_FOLDER]" >&2
  exit 2
fi
if [ ! -d "$GAME_DIR" ]; then echo "Game folder not found: $GAME_DIR" >&2; exit 2; fi
if [ ! -f "$KEYS_FILE" ]; then echo "prod.keys not found: $KEYS_FILE" >&2; exit 2; fi
mkdir -p "$OUT_DIR"
# Android-visible paths are mounted into Ubuntu at /storage/shared.
inside_path() {
  case "$1" in
    /storage/emulated/0/*) printf '/storage/shared/%s' "${1#/storage/emulated/0/}" ;;
    /storage/emulated/0) printf '/storage/shared' ;;
    *) printf '%s' "$1" ;;
  esac
}
GAME_IN=$(inside_path "$GAME_DIR")
KEYS_IN=$(inside_path "$KEYS_FILE")
OUT_IN=$(inside_path "$OUT_DIR")
proot-distro login ubuntu --bind /storage/emulated/0:/storage/shared -- bash -lc '
  set -euo pipefail
  source "$HOME/nx2a-env.sh"
  cd /storage/shared/nx2android-mobile
  python -m porter doctor --json
  python -m porter port "$1" --keys "$2" --out "$3" --progress lines --jobs 4
' _ "$GAME_IN" "$KEYS_IN" "$OUT_IN"
echo "Port finished. Output: $OUT_DIR"
