#import "AdaptyUiFlutterPlugin.h"
#if __has_include(<adapty_ui_flutter/adapty_ui_flutter-Swift.h>)
#import <adapty_ui_flutter/adapty_ui_flutter-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "adapty_ui_flutter-Swift.h"
#endif

@implementation AdaptyUiFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAdaptyUiFlutterPlugin registerWithRegistrar:registrar];
}
@end
