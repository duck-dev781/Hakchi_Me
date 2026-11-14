#import "DeviceDetector.h"
#import <IOKit/IOKitLib.h>

@implementation DeviceDetector

+ (BOOL)isFELDeviceConnected {
    // Common Allwinner FEL USB identity. This is a read-only presence check,
    // not a model-authentication or safe-to-flash check.
    CFMutableDictionaryRef matching = IOServiceMatching("IOUSBDevice");
    if (!matching) return NO;

    int vendor = 0x1f3a;
    int product = 0xefe8;
    CFNumberRef vendorNumber = CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &vendor);
    CFNumberRef productNumber = CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &product);
    if (vendorNumber) CFDictionarySetValue(matching, CFSTR("idVendor"), vendorNumber);
    if (productNumber) CFDictionarySetValue(matching, CFSTR("idProduct"), productNumber);

    io_iterator_t iterator = IO_OBJECT_NULL;
    kern_return_t result = IOServiceGetMatchingServices(kIOMasterPortDefault, matching, &iterator);
    if (vendorNumber) CFRelease(vendorNumber);
    if (productNumber) CFRelease(productNumber);
    if (result != KERN_SUCCESS) return NO;

    io_service_t service = IO_OBJECT_NULL;
    BOOL found = NO;
    while ((service = IOIteratorNext(iterator)) != IO_OBJECT_NULL) {
        found = YES;
        IOObjectRelease(service);
    }
    IOObjectRelease(iterator);
    return found;
}

+ (NSString *)statusDescription {
    if ([self isFELDeviceConnected]) {
        return @"A USB device matching the common Allwinner FEL ID is present. Model and state are not verified.";
    }
    return @"No matching Allwinner FEL USB device detected.";
}
@end
