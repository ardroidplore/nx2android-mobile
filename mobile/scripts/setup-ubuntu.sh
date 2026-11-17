#!/usr/bin/env bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y ca-certificates curl wget unzip git python3 python3-venv python3-pip build-essential cmake ninja-build pkg-config clang lld openjdk-17-jdk zlib1g-dev liblz4-dev libssl-dev file

# .NET 10 official installer supports Linux ARM64 binaries. Microsoft's Ubuntu
# apt feed is x64-only, so do not use packages.microsoft.com on this ARM64 host.
mkdir -p "$HOME/.dotnet"
curl -fsSL https://dot.net/v1/dotnet-install.sh -o /tmp/dotnet-install.sh
bash /tmp/dotnet-install.sh --channel 10.0 --architecture arm64 --install-dir "$HOME/.dotnet"

# Google publishes the r27c Linux host tools for x86_64, not Linux AArch64.
# Do not silently download the x86_64 archive onto the Poco F6. Supply a
# community-built linux-aarch64 NDK r27c-compatible tree at this location.
TOOLS="$HOME/nx2a-toolchains"
NDK="$TOOLS/android-ndk-r27c"
mkdir -p "$TOOLS"
if [ ! -x "$NDK/toolchains/llvm/prebuilt/linux-aarch64/bin/clang" ]; then
  cat <<'MSG'
STOP: a Linux AArch64-host NDK r27c toolchain is not installed.
Google's official android-ndk-r27c-linux.zip contains x86_64 host tools and
cannot run natively in this ARM64 Ubuntu environment. Obtain/build a trusted
linux-aarch64-host NDK compatible with r27c, then place it at:
  $HOME/nx2a-toolchains/android-ndk-r27c
The original nx2android project pins NDK 27.2.12479018; a different revision
is unverified. Do not use a random prebuilt toolchain without reviewing it.
MSG
  exit 3
fi

python3 -m venv "$HOME/nx2a-venv"
"$HOME/nx2a-venv/bin/pip" install --upgrade pip wheel
REPO="/storage/shared/nx2android-mobile"
"$HOME/nx2a-venv/bin/pip" install -r "$REPO/mobile/requirements-mobile.txt"
cat > "$HOME/nx2a-env.sh" <<ENV
export ANDROID_NDK_HOME="$NDK"
export DOTNET_ROOT="$HOME/.dotnet"
export PATH="$HOME/nx2a-venv/bin:$HOME/.dotnet:\$PATH"
export NX2A_HOME="$HOME/.config/nx2android-mobile"
ENV
mkdir -p "$HOME/.config/nx2android-mobile"
echo
echo "Python and .NET installed. Run: source ~/nx2a-env.sh"
echo "Then set your own keys: python -m porter config keys /storage/shared/keys/prod.keys"
echo "Check: python -m porter doctor"
