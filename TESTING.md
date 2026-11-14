# Test plan

## Automated GitHub Actions checks

The `Build Hakchi Me for OS X El Capitan` workflow:
1. Downloads the OS X 10.11 SDK archive and verifies its SHA-256 checksum.
2. Compiles an x86_64-only app with a 10.11 deployment target.
3. Validates the app's Info.plist and executable architecture.
4. Checks the executable's minimum OS load-command metadata.
5. Packages the app into a DMG and publishes the app, DMG and SHA-256 checksum as artifacts.

These checks validate compilation and packaging, not actual runtime compatibility on the 2008 iMac.

## Required test on the target Mac

1. Copy the DMG to the 2008 Intel iMac running OS X 10.11.6.
2. Open the DMG and copy Hakchi Me.app into Applications.
3. Launch it and confirm the Dashboard appears.
4. Open Games and import a small, user-owned `.nes` file.
5. Confirm the title appears in the table.
6. Remove the selected title and confirm only the app's library copy is removed.
7. Import an unsupported extension and confirm it is rejected.
8. Open Backups, select a harmless test file, and confirm a copy plus SHA-256 manifest are created.
9. Confirm the source file remains unchanged.

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
- No physical El Capitan runtime test has been completed.

## Compatibility

The target is 64-bit Intel OS X 10.11 or later. The CI SDK build does not replace testing on the actual 2008 iMac.
