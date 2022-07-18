//
//  AppDelegate.m
//

#import "AppDelegate.h"
#import "vu_app_lifecycle.hpp"
#import "vu_lifetime_accessor.hpp"

using namespace yas;
using namespace yas::vu;

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    lifetime_accessor::app_lifecycle()->add_lifetime();
    return YES;
}

@end
