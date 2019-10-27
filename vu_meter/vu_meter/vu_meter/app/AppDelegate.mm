//
//  AppDelegate.m
//

#import "AppDelegate.h"
#import "RMSViewController.h"
#import "vu_main.hpp"

using namespace yas;

@implementation AppDelegate {
    vu::main_ptr_t _main;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self->_main = vu::main::make_shared();

    UIViewController *rootViewController = self.window.rootViewController;
    if ([rootViewController isKindOfClass:[RMSViewController class]]) {
        [(RMSViewController *)rootViewController set_vu_main:self->_main];
    }

    return YES;
}

- (void)dealloc {
    [_window release];

    yas_super_dealloc();
}

@end
