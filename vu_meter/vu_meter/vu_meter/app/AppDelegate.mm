//
//  AppDelegate.m
//

#import "AppDelegate.h"
#import "vu_app.h"

using namespace yas;
using namespace yas::vu;

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    app_setup::setup();
    return YES;
}

@end
