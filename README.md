# Hakchi Me

A lightweight, native Objective-C / AppKit application intended to bring Hakchi2 CE-style Classic Mini management to older Intel Macs.

## Primary compatibility target

- **Intel Macs running OS X 10.11 El Capitan or later.**
- Specifically developed around a 64-bit Intel Mac such as the 2008 iMac.
- Builds an x86_64-only app; no Apple Silicon slice or newer-only frameworks.
- Uses AppKit, IOKit and CoreFoundation.
- No SwiftUI, Electron, virtualization, Windows runtime, or mandatory kernel extension.

The application is compiled against the OS X 10.11 SDK with a 10.11 deployment target. GitHub Actions downloads the SDK archive, verifies its SHA-256 checksum, and builds the Intel app. The SDK package is sourced from the public macOS SDK collection; review its licensing and provenance before redistributing SDK contents. The SDK is used only in CI and is not bundled into the app.

## Current prototype

- Native graphical window with Dashboard, Games, Backups and Kernel sections.
- Imports local NES/FDS/UNIF game files into the app's own library folder.
- Lists imported games and supports removing library copies.
- Creates timestamped backup copies with SHA-256 manifests.
- Detects the common Allwinner FEL USB identity (VID 1f3a / PID efe8) using IOKit.
- Includes technical research notes for the FEL, post-boot transport, kernel workflow and external storage architecture.
- GitHub Actions builds an Intel app targeted at OS X 10.11 and packages a DMG.

## Kernel and USB status

**Console flashing is not implemented yet.** Current USB detection is read-only and does not send FEL commands. The Kernel screen is a planning/status screen, not a working flasher.

The researched design has two communication stages:

1. FEL / Allwinner BootROM communication to verify the board and temporarily boot the required environment.
2. A separate post-boot USB network/console-management transport for backup, install, repair, uninstall and game synchronization.

Research indicates that a separate kernel driver is not normally required for the FEL stage: XFEL uses libusb on macOS. Hakchi Me will prefer user-space USB access and will only add a privileged helper if testing proves one is necessary.

The app is intended to use the official Hakchi2 CE-compatible kernel/payload workflow, not an invented kernel format. Payload compatibility, board identification, backup validation, transfer verification and recovery handling must be implemented and tested before write operations are enabled.

See [docs/RESEARCH.md](docs/RESEARCH.md) for source notes and implementation gates.

## Build locally on El Capitan

Requires Xcode 7.3 / Command Line Tools or another compiler and SDK combination that supports OS X 10.11:

```sh
make
open "build/Hakchi Me.app"
```

The default build is Intel x86_64 with a 10.11 deployment target. On an older Mac, use the SDK installed with Xcode rather than downloading a newer SDK.

## GitHub Actions

Every push to `main`, pull request, or manual workflow run triggers:

1. Downloads the OS X 10.11 SDK archive and verifies its SHA-256.
2. Compiles the Intel x86_64 app against that SDK with a 10.11 minimum.
3. Validates the executable architecture and bundle minimum version.
4. Creates a DMG and SHA-256 checksum.
5. Uploads the app and DMG as workflow artifacts.

CI compilation and bundle checks do not replace a launch test on a physical El Capitan Mac. The CI artifact is not Developer ID signed or notarized.

## Project layout

- `Sources/main.m` — app entry point
- `Sources/AppDelegate.*` — native UI and user workflows
- `Sources/DeviceDetector.*` — read-only FEL USB identity detection
- `Sources/GameLibrary.*` — local game-library and backup utilities
- `.github/workflows/build-macos.yml` — El Capitan SDK build and DMG workflow
- `docs/RESEARCH.md` — researched protocol and product architecture

## License

GPL-3.0-or-later. Hakchi2 CE and its contributors retain their respective copyrights; this project is an independent macOS frontend and does not imply endorsement.
