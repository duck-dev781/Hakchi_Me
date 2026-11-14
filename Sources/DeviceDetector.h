#import <Foundation/Foundation.h>

@interface DeviceDetector : NSObject
+ (BOOL)isFELDeviceConnected;
+ (NSString *)statusDescription;
@end
