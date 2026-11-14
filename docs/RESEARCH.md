# Hakchi Me: technical research notes

Research snapshot: 2026-11-14

This document separates upstream Hakchi behavior from the implementation plan for Hakchi Me.

## 1. What the original Hakchi workflow does

The Hakchi2 CE FAQ explains that the NES/SNES Classic uses an Allwinner BootROM FEL routine. FEL allows a host to upload code into RAM and execute it. Hakchi uses that temporary environment to read the Linux kernel, prepare the custom-kernel workflow, and run the relevant boot process.

Source: https://github.com/TeamShinkansen/Hakchi2-CE/wiki/FAQ

The important implication is that detecting USB VID/PID 1f3a:efe8 is only device discovery. It is not a complete FEL transport and does not prove the board model. A real implementation needs protocol-level verification and model checks.

## 2. Driver strategy

The XFEL project documents a macOS-capable Allwinner FEL tool built on libusb-1.0 and explicitly says that it does not require a kernel driver.

Sources:
- https://xfel.xboot.org/en/guide/intro/
- https://xfel.xboot.org/en/guide/build-guide/
- https://github.com/xboot/xfel

Hakchi Me should therefore start with user-space USB access through a maintained USB library. A privileged PKG, kernel extension, or system driver should not be installed unless a tested macOS permission limitation proves it is necessary. This avoids an unnecessary privileged component and reduces installation friction.

## 3. Two-stage console communication

The upstream Hakchi process uses FEL to bootstrap a temporary runtime. The temporary runtime then exposes a different USB communication path used by the host for the remaining management operations.

A public native macOS implementation, Swift Hakchi2, documents the same broad split:
- FEL / Allwinner BootROM for the initial memory boot.
- A USB network gadget followed by SSH for console management.

Reference implementation for research only:
https://github.com/mattackerman808/swift-hakchi2

Hakchi Me is not copying that project's source. Its architecture should be implemented independently in Objective-C/C, with license and provenance checks before any third-party code is incorporated.

## 4. Kernel menu behavior to match

The Hakchi2 CE documentation describes these distinct actions:
- Install / Repair: installs or reinstalls the kernel mod and /hakchi directory while preserving existing data where supported.
- Reset: removes the /hakchi directory and installs it again; this removes ROMs and modules from NAND.
- Uninstall: removes the Hakchi modification and restores stock behavior, while retaining saves.
- Factory Reset: uninstall plus removal of saves.

Source: https://teamshinkansen.github.io/docs/hakchi_GUI.html

The FAQ also describes the stock-kernel backup and re-flash recovery path. Hakchi Me must treat backup and verification as prerequisites for destructive operations.

## 5. External storage is a separate workflow

The Hakchi USB storage guide says external storage requires a compatible OTG arrangement, a suitable USB storage device, and a custom kernel with USB host enabled. The Hakchi CE GUI documentation describes exporting games to a USB drive and syncing to that drive when connected.

Sources:
- https://github.com/ClusterM/hakchi2/wiki/USB-storage-guide
- https://teamshinkansen.github.io/docs/hakchi_GUI.html

So storage expansion should not be confused with FEL flashing. It belongs after the custom kernel and USB-host feature are correctly installed.

## 6. Build and packaging

The project uses a native AppKit application and Makefile so it does not require SwiftUI, Electron, a VM, or a Windows runtime.

GitHub Actions will:
1. Build on a macOS hosted runner.
2. Validate the app bundle and architecture slices.
3. Assemble a DMG.
4. Publish the app, DMG, and SHA-256 file as workflow artifacts.

The CI artifact is unsigned/ad-hoc signed at most and is not notarized. A Developer ID certificate and Apple notarization credentials are required for a normal signed/notarized public release.

Reference: https://developer.apple.com/documentation/xcode/packaging-mac-software-for-distribution

## 7. Implementation gates before enabling flash operations

- Verify exact console model / board ID, not only USB VID/PID.
- Validate every required payload's origin, size, format, and checksum.
- Dump and verify the original kernel before modifying console storage.
- Implement and test FEL transfers with explicit timeouts and cancellation.
- Verify the post-boot USB network transport separately.
- Verify each console-side command and its exit status.
- Read back and verify any data that is written.
- Keep install, repair, reset, uninstall, and factory reset as distinct workflows.
- Never label a menu action as working until the underlying operation has been tested against the supported console model.

