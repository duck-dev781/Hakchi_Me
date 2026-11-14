#import "GameLibrary.h"
#import <CommonCrypto/CommonDigest.h>

@implementation GameLibrary

+ (NSString *)applicationDataPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *base = [paths count] ? [paths objectAtIndex:0] : NSHomeDirectory();
    return [base stringByAppendingPathComponent:@"Hakchi Me"];
}

+ (NSString *)libraryPath {
    return [[self applicationDataPath] stringByAppendingPathComponent:@"Games"];
}

+ (NSArray *)gameFiles {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *folder = [self libraryPath];
    [fm createDirectoryAtPath:folder withIntermediateDirectories:YES attributes:nil error:nil];
    NSArray *items = [fm contentsOfDirectoryAtPath:folder error:nil];
    NSMutableArray *games = [NSMutableArray array];
    NSSet *extensions = [NSSet setWithObjects:@"nes", @"fds", @"unf", @"unif", nil];
    for (NSString *name in items) {
        if ([extensions containsObject:[[name pathExtension] lowercaseString]]) {
            [games addObject:[folder stringByAppendingPathComponent:name]];
        }
    }
    return [games sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

+ (BOOL)addGameAtURL:(NSURL *)url error:(NSError **)error {
    NSString *ext = [[url pathExtension] lowercaseString];
    NSSet *allowed = [NSSet setWithObjects:@"nes", @"fds", @"unf", @"unif", nil];
    if (![allowed containsObject:ext]) {
        if (error) *error = [NSError errorWithDomain:@"HakchiMe" code:1 userInfo:
            [NSDictionary dictionaryWithObject:@"Unsupported file type. Choose .nes, .fds, .unf or .unif." forKey:NSLocalizedDescriptionKey]];
        return NO;
    }
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *folder = [self libraryPath];
    [fm createDirectoryAtPath:folder withIntermediateDirectories:YES attributes:nil error:error];
    NSString *destination = [folder stringByAppendingPathComponent:[url lastPathComponent]];
    if ([fm fileExistsAtPath:destination]) {
        NSString *base = [[url lastPathComponent] stringByDeletingPathExtension];
        NSString *newName = [NSString stringWithFormat:@"%@-%@.%@", base,
            [[NSProcessInfo processInfo] globallyUniqueString], ext];
        destination = [folder stringByAppendingPathComponent:newName];
    }
    return [fm copyItemAtURL:url toURL:[NSURL fileURLWithPath:destination] error:error];
}

+ (BOOL)removeGameAtPath:(NSString *)path error:(NSError **)error {
    NSString *root = [[self libraryPath] stringByStandardizingPath];
    NSString *candidate = [path stringByStandardizingPath];
    if (![candidate hasPrefix:[root stringByAppendingString:@"/"]]) {
        if (error) *error = [NSError errorWithDomain:@"HakchiMe" code:2 userInfo:
            [NSDictionary dictionaryWithObject:@"Refusing to remove a file outside the Hakchi Me library." forKey:NSLocalizedDescriptionKey]];
        return NO;
    }
    return [[NSFileManager defaultManager] removeItemAtPath:candidate error:error];
}

+ (NSString *)sha256ForFileAtPath:(NSString *)path {
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:path];
    if (!handle) return nil;
    CC_SHA256_CTX ctx;
    CC_SHA256_Init(&ctx);
    @try {
        NSData *chunk = nil;
        while ((chunk = [handle readDataOfLength:1024 * 1024]) && [chunk length] > 0) {
            CC_SHA256_Update(&ctx, [chunk bytes], (CC_LONG)[chunk length]);
        }
    } @catch (NSException *exception) {
        [handle closeFile];
        return nil;
    }
    [handle closeFile];
    unsigned char digest[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256_Final(digest, &ctx);
    NSMutableString *hex = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) [hex appendFormat:@"%02x", digest[i]];
    return hex;
}

+ (BOOL)makeBackupOfFileAtURL:(NSURL *)url error:(NSError **)error {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *folder = [[self applicationDataPath] stringByAppendingPathComponent:@"Backups"];
    [fm createDirectoryAtPath:folder withIntermediateDirectories:YES attributes:nil error:error];
    NSString *stamp = [[NSDate date] description];
    stamp = [[stamp stringByReplacingOccurrencesOfString:@":" withString:@"-"] stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    NSString *name = [NSString stringWithFormat:@"%@-%@", stamp, [url lastPathComponent]];
    NSString *destination = [folder stringByAppendingPathComponent:name];
    if (![fm copyItemAtURL:url toURL:[NSURL fileURLWithPath:destination] error:error]) return NO;
    NSString *hash = [self sha256ForFileAtPath:destination];
    NSString *manifest = [NSString stringWithFormat:@"File: %@\nSHA-256: %@\n", name, hash ? hash : @"unavailable"];
    NSString *manifestPath = [destination stringByAppendingString:@".sha256.txt"];
    return [manifest writeToFile:manifestPath atomically:YES encoding:NSUTF8StringEncoding error:error];
}
@end
