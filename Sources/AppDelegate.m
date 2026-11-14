#import "AppDelegate.h"
#import "DeviceDetector.h"
#import "GameLibrary.h"
#import <QuartzCore/QuartzCore.h>

@interface AppDelegate ()
@property (nonatomic, strong) NSWindow *window;
@property (nonatomic, strong) NSView *contentView;
@property (nonatomic, strong) NSTableView *gamesTable;
@property (nonatomic, strong) NSArray *games;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    (void)notification;
    [self buildWindow];
    [self showDashboard:nil];
    [self.window makeKeyAndOrderFront:nil];
    [NSApp activateIgnoringOtherApps:YES];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    (void)sender;
    return YES;
}

- (NSButton *)button:(NSString *)title action:(SEL)action frame:(NSRect)frame {
    NSButton *button = [[NSButton alloc] initWithFrame:frame];
    [button setTitle:title];
    [button setBezelStyle:NSRoundedBezelStyle];
    [button setTarget:self];
    [button setAction:action];
    return button;
}

- (NSTextField *)label:(NSString *)text frame:(NSRect)frame size:(CGFloat)size {
    NSTextField *label = [[NSTextField alloc] initWithFrame:frame];
    [label setStringValue:text ? text : @""];
    [label setEditable:NO];
    [label setSelectable:YES];
    [label setBordered:NO];
    [label setDrawsBackground:NO];
    [label setFont:[NSFont systemFontOfSize:size]];
    return label;
}

- (void)buildWindow {
    self.window = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 920, 610)
        styleMask:(NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask | NSResizableWindowMask)
        backing:NSBackingStoreBuffered defer:NO];
    [self.window setTitle:@"Hakchi Me"];
    [self.window center];

    NSView *root = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 920, 610)];
    [self.window setContentView:root];

    NSView *sidebar = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 190, 610)];
    [sidebar setWantsLayer:YES];
    sidebar.layer.backgroundColor = [[NSColor colorWithCalibratedRed:0.12 green:0.14 blue:0.18 alpha:1] CGColor];
    [root addSubview:sidebar];

    NSTextField *brand = [self label:@"HAKCHI ME" frame:NSMakeRect(22, 555, 150, 28) size:18];
    [brand setTextColor:[NSColor whiteColor]];
    [sidebar addSubview:brand];

    NSArray *titles = [NSArray arrayWithObjects:@"Dashboard", @"Games", @"Backups", @"Kernel", nil];
    SEL actions[] = {@selector(showDashboard:), @selector(showGames:), @selector(showBackups:), @selector(showKernel:)};
    for (NSUInteger i = 0; i < [titles count]; i++) {
        NSButton *b = [self button:[titles objectAtIndex:i] action:actions[i] frame:NSMakeRect(15, 490 - (i * 48), 160, 34)];
        [b setAlignment:NSLeftTextAlignment];
        [sidebar addSubview:b];
    }

    self.contentView = [[NSView alloc] initWithFrame:NSMakeRect(210, 20, 690, 570)];
    [root addSubview:self.contentView];
}

- (void)clearContent {
    for (NSView *view in [[self.contentView subviews] copy]) [view removeFromSuperview];
}

- (void)addTitle:(NSString *)title subtitle:(NSString *)subtitle {
    [self.contentView addSubview:[self label:title frame:NSMakeRect(10, 520, 650, 34) size:25]];
    [self.contentView addSubview:[self label:subtitle frame:NSMakeRect(10, 490, 650, 24) size:12]];
}

- (void)showDashboard:(id)sender {
    (void)sender;
    [self clearContent];
    [self addTitle:@"Welcome to Hakchi Me" subtitle:@"A native Mac frontend for your Classic Mini library."];
    NSTextField *device = [self label:[DeviceDetector statusDescription] frame:NSMakeRect(10, 420, 650, 48) size:13];
    [device setTextColor:[NSColor colorWithCalibratedWhite:0.35 alpha:1.0]];
    [self.contentView addSubview:device];
    [self.contentView addSubview:[self label:@"Quick start" frame:NSMakeRect(10, 350, 200, 25) size:17]];
    [self.contentView addSubview:[self label:@"1. Add your own game files in Games.\n2. Keep an original kernel backup before any device changes.\n3. Connect the Classic with a data-capable USB cable to check FEL detection." frame:NSMakeRect(10, 275, 640, 65) size:13]];
    [self.contentView addSubview:[self label:@"Device writing is not enabled in this prototype." frame:NSMakeRect(10, 190, 640, 30) size:13]];
    [self.contentView addSubview:[self button:@"Refresh device status" action:@selector(showDashboard:) frame:NSMakeRect(10, 135, 190, 32)]];
}

- (void)showGames:(id)sender {
    (void)sender;
    [self clearContent];
    [self addTitle:@"Game Library" subtitle:@"Import and organize local game files. No console changes are made here."];
    self.games = [GameLibrary gameFiles];
    NSScrollView *scroll = [[NSScrollView alloc] initWithFrame:NSMakeRect(10, 85, 650, 380)];
    [scroll setHasVerticalScroller:YES];
    self.gamesTable = [[NSTableView alloc] initWithFrame:NSMakeRect(0, 0, 640, 370)];
    NSTableColumn *column = [[NSTableColumn alloc] initWithIdentifier:@"game"];
    [column setWidth:620];
    [[column headerCell] setStringValue:@"Imported games"];
    [self.gamesTable addTableColumn:column];
    [self.gamesTable setDataSource:(id)self];
    [self.gamesTable setDelegate:(id)self];
    [scroll setDocumentView:self.gamesTable];
    [self.contentView addSubview:scroll];
    [self.contentView addSubview:[self button:@"Add Games…" action:@selector(addGames:) frame:NSMakeRect(10, 35, 130, 32)]];
    [self.contentView addSubview:[self button:@"Remove Selected" action:@selector(removeSelectedGame:) frame:NSMakeRect(150, 35, 150, 32)]];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    (void)tableView;
    return (NSInteger)[self.games count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)column row:(NSInteger)row {
    (void)tableView; (void)column;
    return [[[self.games objectAtIndex:(NSUInteger)row] lastPathComponent] stringByDeletingPathExtension];
}

- (void)addGames:(id)sender {
    (void)sender;
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setAllowsMultipleSelection:YES];
    [panel setCanChooseDirectories:NO];
    [panel setAllowedFileTypes:[NSArray arrayWithObjects:@"nes", @"fds", @"unf", @"unif", nil]];
    if ([panel runModal] == NSOKButton) {
        for (NSURL *url in [panel URLs]) {
            NSError *error = nil;
            if (![GameLibrary addGameAtURL:url error:&error]) [self showError:error];
        }
        [self showGames:nil];
    }
}

- (void)removeSelectedGame:(id)sender {
    (void)sender;
    NSInteger row = [self.gamesTable selectedRow];
    if (row < 0 || row >= (NSInteger)[self.games count]) return;
    NSError *error = nil;
    if (![GameLibrary removeGameAtPath:[self.games objectAtIndex:(NSUInteger)row] error:&error]) [self showError:error];
    [self showGames:nil];
}

- (void)showBackups:(id)sender {
    (void)sender;
    [self clearContent];
    [self addTitle:@"Backups" subtitle:@"Create a local copy and SHA-256 manifest for a file you select."];
    [self.contentView addSubview:[self label:@"Choose an original kernel dump or another file you want to preserve." frame:NSMakeRect(10, 425, 640, 40) size:13]];
    [self.contentView addSubview:[self button:@"Create Backup…" action:@selector(createBackup:) frame:NSMakeRect(10, 365, 150, 32)]];
    [self.contentView addSubview:[self label:@"Backups are stored in ~/Library/Application Support/Hakchi Me/Backups." frame:NSMakeRect(10, 310, 650, 30) size:12]];
}

- (void)createBackup:(id)sender {
    (void)sender;
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setAllowsMultipleSelection:NO];
    [panel setCanChooseDirectories:NO];
    if ([panel runModal] == NSOKButton) {
        NSError *error = nil;
        if ([GameLibrary makeBackupOfFileAtURL:[panel URL] error:&error]) {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert setMessageText:@"Backup created"];
            [alert setInformativeText:@"A copy and SHA-256 manifest were saved in the Backups folder."];
            [alert runModal];
        } else [self showError:error];
    }
}

- (void)showKernel:(id)sender {
    (void)sender;
    [self clearContent];
    [self addTitle:@"Kernel & Console" subtitle:@"Hakchi2 CE-compatible workflow — preparation stage only."];
    [self.contentView addSubview:[self label:@"This build does not flash, erase, patch, or write to the console." frame:NSMakeRect(10, 425, 650, 28) size:14]];
    [self.contentView addSubview:[self label:@"Planned stages:\n• Identify the exact console model and boot state\n• Validate the original kernel dump and its checksum\n• Prepare the Hakchi2 CE-compatible payload set\n• Verify transfer and read-back before any write is offered" frame:NSMakeRect(10, 325, 650, 90) size:13]];
    [self.contentView addSubview:[self label:@"Status: FEL presence detection only. Kernel operations are not implemented." frame:NSMakeRect(10, 245, 650, 30) size:12]];
}

- (void)showError:(NSError *)error {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setAlertStyle:NSCriticalAlertStyle];
    [alert setMessageText:@"Operation failed"];
    [alert setInformativeText:[error localizedDescription] ? [error localizedDescription] : @"An unknown error occurred."];
    [alert runModal];
}
@end
