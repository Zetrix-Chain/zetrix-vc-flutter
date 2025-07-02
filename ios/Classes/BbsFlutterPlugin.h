#import <Flutter/Flutter.h>

@interface BbsFlutterPlugin : NSObject<FlutterPlugin>

// Helper methods for byte array conversion
- (NSArray<NSNumber *> *)toList:(NSData *)data;
- (NSData *)byteListToArray:(NSArray<NSNumber *> *)list;

@end
