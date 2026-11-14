# Test plan

## Automated GitHub Actions checks

The `Build Hakchi Me for macOS` workflow:
1. Compiles x86_64 and arm64 slices on a macOS runner.
2. Creates a universal executable with `lipo`.
3. Validates the app's Info.plist.
4. Confirms the executable exists and is executable.
5. Packages the app into a DMG and publishes the app, DMG and SHA-256 checksum as artifacts.

These checks validate compilation and packaging, not actual console compatibility.

## Local-only paths

1. Launch the app and confirm the Dashboard appears.
2. Open Games and import a small, user-owned `.nes` file.
3. Confirm the title appears in the table.
4. Remove the selected title and confirm only the app's library copy is removed.
5. Import a file with an unsupported extension and confirm it is rejected.
6. Open Backups, select a harmless test file, and confirm a copy plus SHA-256 manifest are created.
7. Confirm the source file remains unchanged.

## USB detection

1. Launch without a console connected; expect the no-device message.
2. If a device with the common Allwinner FEL USB identity is connected, expect the presence message.
3. Treat a match as a USB identity hint only. Do not infer console model, firmware state, or write safety from it.

## Not covered yet

- No FEL protocol commands are sent.
- No board ID verification is implemented.
- No kernel or bootloader is read or written.
- No payload is uploaded or executed.
- No post-boot USB network/SSH transport is implemented.
- No storage partition is resized or modified.
- No game synchronization to a console is performed.
- No NES Classic hardware test has been completed.

## Compatibility

The CI build targets Intel macOS 10.13+ and Apple Silicon macOS 11.0+. Older 10.x compatibility is not currently verified.
