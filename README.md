# Hakchi Me

A lightweight, native Objective-C / AppKit application intended to bring Hakchi2 CE-style Classic Mini management to macOS.

## Compatibility

- Intel Macs: macOS 10.13 or later.
- Apple Silicon: macOS 11.0 or later.
- Builds a universal x86_64 + arm64 app by default.
- Uses AppKit, IOKit, CoreFoundation, QuartzCore and CommonCrypto.
- No SwiftUI, Electron, virtualization, Windows runtime, or mandatory kernel extension.

The original 10.7 target has been raised because the current supported Xcode/macOS build environment cannot reliably validate a 10.7 deployment. Supporting older 10.x releases would require a separate legacy toolchain and SDK validation.

## Current prototype

- Native graphical window with Dashboard, Games, Backups and Kernel sections.
- Imports local NES/FDS/UNIF game files into the app's library folder.
- Lists imported games and supports removing library copies.
- Creates timestamped backup copies with SHA-256 manifests.
- Detects the common Allwinner FEL USB identity (VID 1f3a / PID efe8) using IOKit.
- Includes technical research notes for the FEL, post-boot transport, kernel workflow and external storage architecture.
- GitHub Actions builds the universal app and packages a DMG on macOS.

## Kernel and USB status

**Console flashing is not implemented yet.** Current USB detection is read-only and does not send FEL commands. The Kernel screen is a planning/status screen, not a working flasher.

The researched design has two communication stages:

1. FEL / Allwinner BootROM communication to verify the board and temporarily boot the required environment.
2. A separate post-boot USB network/console-management transport for backup, install, repair, uninstall and game synchronization.

Research indicates that a separate kernel driver is not normally required for the FEL stage: XFEL uses libusb on macOS. Hakchi Me will prefer user-space USB access and will only add a privileged helper if testing proves one is necessary.

The app is intended to use the official Hakchi2 CE-compatible kernel/payload workflow, not an invented kernel format. Payload compatibility, board identification, backup validation, transfer verification and recovery handling must be implemented and tested before write operations are enabled.

See [docs/RESEARCH.md](docs/RESEARCH.md) for source notes and implementation gates.

## Build locally

Requires a Mac with Xcode Command Line Tools:

```sh
make
open "build/Hakchi Me.app"
```

Build only for Intel:

```sh
make clean
make ARCHS=x86_64
```

Build only for Apple Silicon:

```sh
make clean
make ARCHS=arm64
```

## GitHub Actions

Every push to `main`, pull request, or manual workflow run triggers:

1. Universal app compilation on a macOS runner.
2. Bundle and architecture validation.
3. DMG creation.
4. Upload of the app, DMG and SHA-256 checksum as a workflow artifact.

The CI artifact is not Developer ID signed or notarized. Those release steps require the project owner's Apple Developer signing credentials and notarization secrets.

## Project layout

- `Sources/main.m` — app entry point
- `Sources/AppDelegate.*` — native UI and user workflows
- `Sources/DeviceDetector.*` — read-only FEL USB identity detection
- `Sources/GameLibrary.*` — local game-library and backup utilities
- `.github/workflows/build-macos.yml` — macOS build and DMG workflow
- `docs/RESEARCH.md` — researched protocol and product architecture

## License

GPL-3.0-or-later. Hakchi2 CE and its contributors retain their respective copyrights; this project is an independent macOS frontend and does not imply endorsement.
