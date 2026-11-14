# Hakchi Me

A native Objective-C / AppKit project for managing Nintendo Classic Mini libraries on older Intel Macs.

## Compatibility target

- Designed for OS X 10.7 and later (Intel).
- Uses AppKit, IOKit and CommonCrypto; no SwiftUI, Electron, virtualization, or Windows runtime.
- Build with Apple's Xcode command-line tools on a Mac.

## Current prototype

- Native graphical window with Dashboard, Games, Backups and Kernel sections.
- Imports local NES/FDS/UNIF game files into the app's library folder.
- Lists imported games and supports removing library copies.
- Creates timestamped, SHA-256-verified copies of user-selected backup files.
- Detects the common Allwinner FEL USB identity (VID 1f3a / PID efe8) using IOKit.

## Important implementation boundary

This first commit is intentionally **non-flashing**. Device detection is not proof that a particular Classic model or boot state is safe to write. The kernel/payload pipeline is not implemented yet, and the app does not write to USB devices or alter console storage.

The project is intended to use the **official Hakchi2 CE-compatible kernel/payload format**, not a newly invented kernel. The payload itself is not bundled; users must supply their own legally obtained, model-appropriate backup/payload. Before enabling writes, the implementation needs verified model identification, payload/version checks, a tested FEL transport, read-back verification, and recovery handling.

## Build

```sh
make
open "build/Hakchi Me.app"
```

Or:

```sh
make clean
make
```

The Makefile sets a 10.7 deployment target. A sufficiently old Xcode/SDK is required to produce a binary that runs on older OS X releases. Building on a newer macOS does not guarantee compatibility with every 10.x release.

## Project layout

- `Sources/main.m` — app entry point
- `Sources/AppDelegate.*` — native UI and user workflows
- `Sources/DeviceDetector.*` — read-only FEL USB detection
- `Sources/GameLibrary.*` — local game-library and backup utilities

## License

GPL-3.0-or-later. Hakchi2 CE and its contributors retain their respective copyrights; this project is an independent macOS frontend and does not imply endorsement.
