//
//  vu_settings_tests.mm
//

#import <XCTest/XCTest.h>
#import "vu_settings.hpp"

using namespace yas;
using namespace yas::vu;

@interface vu_settings_tests : XCTestCase

@end

@implementation vu_settings_tests

- (void)setUp {
    [self clearUserDefaults];
}

- (void)tearDown {
    [self clearUserDefaults];
}

- (void)test_default_reference {
    auto const settings = vu::settings::make_shared();

    XCTAssertEqual(settings->reference(), -20);
}

- (void)test_restore_reference {
    [self setUserDefaultsReference:-10];

    auto const settings = vu::settings::make_shared();

    XCTAssertEqual(settings->reference(), -10);
}

- (void)test_set_reference_from_user_defaults {
    auto const settings = vu::settings::make_shared();

    XCTAssertEqual(settings->reference(), -20);

    [self setUserDefaultsReference:0];

    XCTAssertEqual(settings->reference(), 0);

    [self setUserDefaultsReference:1];

    XCTAssertEqual(settings->reference(), 0);

    [self setUserDefaultsReference:-30];

    XCTAssertEqual(settings->reference(), -30);

    [self setUserDefaultsReference:-31];

    XCTAssertEqual(settings->reference(), -30);
}

#pragma mark - private

- (void)clearUserDefaults {
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:[[NSBundle mainBundle] bundleIdentifier]];
}

- (void)setUserDefaultsReference:(int32_t)reference {
    [[NSUserDefaults standardUserDefaults] setValue:@(reference) forKey:@"reference"];
}

@end
