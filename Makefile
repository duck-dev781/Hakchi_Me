APP_NAME=Hakchi Me
BUNDLE=build/$(APP_NAME).app
SOURCES=Sources/main.m Sources/AppDelegate.m Sources/DeviceDetector.m Sources/GameLibrary.m
SDKROOT?=$(shell xcrun --sdk macosx --show-sdk-path 2>/dev/null)
CC=clang
CFLAGS=-fobjc-arc -Wall -Wextra -mmacosx-version-min=10.7 -ISources
FRAMEWORKS=-framework Cocoa -framework IOKit -framework CoreFoundation -framework QuartzCore
PLIST=Resources/Info.plist

.PHONY: all clean
all: $(BUNDLE)/Contents/MacOS/$(APP_NAME)

$(BUNDLE)/Contents/MacOS/$(APP_NAME): $(SOURCES) $(PLIST)
	mkdir -p $(BUNDLE)/Contents/MacOS $(BUNDLE)/Contents/Resources
	$(CC) $(CFLAGS) $(SOURCES) $(FRAMEWORKS) -o "$@"
	cp $(PLIST) $(BUNDLE)/Contents/Info.plist

clean:
	rm -rf build
