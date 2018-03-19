//
//  AppDelegate.m
//

#import "AppDelegate.h"
#import "vu_main.hpp"

using namespace yas;

@implementation AppDelegate {
    vu::main _main;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self->_main.setup();

    return YES;
}

@end
