//
//  TestAppDelegate.m
//

#import "TestAppDelegate.h"
#import <objc_utils/yas_objc_macros.h>

@implementation TestAppDelegate

- (void)dealloc {
    [_window release];

    yas_super_dealloc();
}

@end
