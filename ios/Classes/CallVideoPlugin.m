#import "CallVideoPlugin.h"
#if __has_include(<call_video/call_video-Swift.h>)
#import <call_video/call_video-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "call_video-Swift.h"
#endif

@implementation CallVideoPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftCallVideoPlugin registerWithRegistrar:registrar];
}
@end
