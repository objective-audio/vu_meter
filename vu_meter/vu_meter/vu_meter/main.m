//
//  main.m
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "TestAppDelegate.h"

int main(int argc, char * argv[]) {
    @autoreleasepool {
        if (NSClassFromString(@"XCTest")) {
            return UIApplicationMain(argc, argv, nil, NSStringFromClass([TestAppDelegate class]));
        } else {
            return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
        }
    }
}
