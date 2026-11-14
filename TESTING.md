# Prototype test plan

This is a manual/static test plan for the first prototype. It has not been run on macOS hardware in this development environment.

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

- No FEL commands are sent.
- No kernel or bootloader is read or written.
- No payload is uploaded or executed.
- No game synchronization to a console is performed.
- No compatibility test has been performed against NES Classic hardware.

## Build verification

Run `make` on a Mac with Xcode command-line tools. This source has received a code-path review, but it has not been compiled in this environment because the current environment is not macOS and does not contain Apple's AppKit/IOKit SDKs.
