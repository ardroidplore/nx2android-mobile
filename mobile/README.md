# nx2android Mobile (experimental fork scaffold)

This folder adds a native Android controller for the existing `porter` pipeline. It does **not** replace or rewrite `porter/` or `nxnative/`.

## Current status

- Native Android launcher project: initial implementation.
- Termux RUN_COMMAND bridge: initial implementation; requires the user to enable external commands in Termux and grant `com.termux.permission.RUN_COMMAND`.
- Linux ARM64 build environment: bootstrap scripts for Ubuntu in `proot-distro`.
- End-to-end build on a Poco F6: **not yet verified**. This scaffold is not a claim that a port already succeeds on Android.

## Why Ubuntu in proot?

Termux runs on Android/Bionic. The upstream port pipeline requires Python 3.11+, .NET SDK 10, Android NDK r27c and native build tools. The Linux .NET SDK targets glibc, so running the pipeline in an Ubuntu ARM64 proot is the first viable experiment. Android's shared storage is bound at `/storage/shared` inside the proot.

## Install on the Poco F6

1. Install Termux from its official F-Droid/GitHub distribution (do not mix APKs from different signing sources).
2. Open Termux and run `termux-setup-storage` and allow access.
3. Copy/extract this repository to `/storage/emulated/0/nx2android-mobile` so that `mobile/scripts/setup-termux.sh` exists there.
4. In Termux, run:

   ```sh
   bash /storage/emulated/0/nx2android-mobile/mobile/scripts/setup-termux.sh
   ```

5. Build/install the Android controller from `mobile/android` using Android Studio or Gradle on a development computer. Then enable **Allow external apps** in Termux settings and grant the controller the Termux RUN_COMMAND permission when prompted.
6. In the app, enter the game dump folder and `prod.keys` path as visible in shared storage, for example `/storage/emulated/0/SwitchDumps/Game` and `/storage/emulated/0/keys/prod.keys`.

## Important limitations

- The game dump and `prod.keys` must be your own legally obtained files. Do not share keys or generated game APK/data packs.
- The first setup installs Python/.NET and needs a separately supplied Linux AArch64-host NDK compatible with the project-pinned r27c. Keep substantial free space; a game port can temporarily need roughly twice the game data size. 512 GB is helpful, but free space still matters.
- The stock `porter tools --download` logic was designed for desktop Linux/macOS/Windows and is not used by this bootstrap. The bootstrap installs Python/.NET ARM64 dependencies separately. Google does not publish an official Linux AArch64 host package for NDK r27c; the setup script deliberately stops until a compatible, trusted `linux-aarch64` NDK is supplied. This is currently the largest blocker to a fully on-phone build.
- `adb` installation from the phone itself is not wired up. The first milestone is producing the APK/data pack in shared storage. Installation can be done from Android's file manager or added later through a dedicated Android installer flow.
- The original project pins NDK 27.2.12479018. The official Google Linux NDK archive is an x86_64-host toolchain; an ARM64-host replacement is community-built and not equivalent to an official Google package. Its compiler, linker and tools must be audited and tested before use. Some upstream build steps may also assume a conventional Android SDK layout. These are the main compatibility items to validate and patch next.
