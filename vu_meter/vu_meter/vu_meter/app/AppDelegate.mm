//
//  AppDelegate.m
//

#import "AppDelegate.h"
#import "RMSViewController.h"
#import "vu_main.hpp"

using namespace yas;

namespace yas::vu {
struct app_delegate_cpp {
    vu::main_ptr_t main = vu::main::make_shared();
};
}

@implementation AppDelegate {
    vu::app_delegate_cpp _cpp;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self->_cpp.main->setup();

    UIViewController *rootViewController = self.window.rootViewController;
    if ([rootViewController isKindOfClass:[RMSViewController class]]) {
        [(RMSViewController *)rootViewController set_vu_main:self->_cpp.main];
    }

    return YES;
}

@end
