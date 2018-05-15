//
//  TestAppDelegate.m
//

#import "TestAppDelegate.h"
#import "yas_objc_macros.h"

@implementation TestAppDelegate

- (void)dealloc {
    [_window release];

    yas_super_dealloc();
}

@end
