//
//  AppDelegate.m
//

#import "AppDelegate.h"
#import <vu-meter-core/lifetimes/global/lifecycles/app_lifecycle.hpp>
#import <vu-meter-core/lifetimes/global/lifetime_accessor.hpp>

using namespace yas;
using namespace yas::vu;

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    lifetime_accessor::app_lifecycle()->add_lifetime();

    return YES;
}

@end
