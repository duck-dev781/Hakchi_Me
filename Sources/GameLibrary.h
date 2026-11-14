#import <Foundation/Foundation.h>

@interface GameLibrary : NSObject
+ (NSString *)libraryPath;
+ (NSArray *)gameFiles;
+ (BOOL)addGameAtURL:(NSURL *)url error:(NSError **)error;
+ (BOOL)removeGameAtPath:(NSString *)path error:(NSError **)error;
+ (BOOL)makeBackupOfFileAtURL:(NSURL *)url error:(NSError **)error;
+ (NSString *)sha256ForFileAtPath:(NSString *)path;
@end
