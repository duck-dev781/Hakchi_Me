APP_NAME=Hakchi Me
BUNDLE=build/$(APP_NAME).app
SOURCES=Sources/main.m Sources/AppDelegate.m Sources/DeviceDetector.m Sources/GameLibrary.m
CC=clang
CFLAGS=-fobjc-arc -Wall -Wextra -ISources
FRAMEWORKS=-framework Cocoa -framework IOKit -framework CoreFoundation
PLIST=Resources/Info.plist

# Hakchi Me's primary target is the 64-bit Intel iMac running OS X 10.11.
ARCHS ?= x86_64
MIN_X86_64 ?= 10.11
SDKROOT ?=
SYSROOT_FLAG = $(if $(SDKROOT),-isysroot "$(SDKROOT)",)

.PHONY: all clean
all:
	mkdir -p "$(BUNDLE)/Contents/MacOS" "$(BUNDLE)/Contents/Resources" build/arch
	$(CC) $(CFLAGS) -arch x86_64 -mmacosx-version-min=$(MIN_X86_64) $(SYSROOT_FLAG) $(SOURCES) $(FRAMEWORKS) -o "$(BUNDLE)/Contents/MacOS/$(APP_NAME)"
	cp $(PLIST) "$(BUNDLE)/Contents/Info.plist"

clean:
	rm -rf build
