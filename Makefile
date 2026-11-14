APP_NAME=Hakchi Me
BUNDLE=build/$(APP_NAME).app
SOURCES=Sources/main.m Sources/AppDelegate.m Sources/DeviceDetector.m Sources/GameLibrary.m
CC=clang
CFLAGS=-fobjc-arc -Wall -Wextra -ISources
FRAMEWORKS=-framework Cocoa -framework IOKit -framework CoreFoundation
PLIST=Resources/Info.plist

# Intel supports the 10.13 deployment target; Apple Silicon requires macOS 11 or newer.
ARCHS ?= x86_64 arm64
MIN_X86_64 ?= 10.13
MIN_ARM64 ?= 11.0

.PHONY: all clean
all:
	mkdir -p "$(BUNDLE)/Contents/MacOS" "$(BUNDLE)/Contents/Resources" build/arch
	set -e; \
	bins=""; \
	for arch in $(ARCHS); do \
		case "$$arch" in \
			x86_64) minimum="$(MIN_X86_64)" ;; \
			arm64) minimum="$(MIN_ARM64)" ;; \
			*) echo "Unsupported architecture: $$arch"; exit 2 ;; \
		esac; \
		output="build/arch/HakchiMe-$$arch"; \
		$(CC) $(CFLAGS) -arch "$$arch" -mmacosx-version-min="$$minimum" $(SOURCES) $(FRAMEWORKS) -o "$$output"; \
		bins="$$bins $$output"; \
	done; \
	lipo -create $$bins -output "$(BUNDLE)/Contents/MacOS/$(APP_NAME)"
	cp $(PLIST) "$(BUNDLE)/Contents/Info.plist"

clean:
	rm -rf build
