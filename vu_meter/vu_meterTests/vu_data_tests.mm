//
//  vu_data_tests.mm
//

#import <XCTest/XCTest.h>
#import "vu_data.hpp"

using namespace yas;
using namespace yas::vu;

@interface vu_data_tests : XCTestCase

@end

@implementation vu_data_tests

- (void)setUp {
    [self clearUserDefaults];
}

- (void)tearDown {
    [self clearUserDefaults];
}

- (void)test_default_reference {
    auto const data = vu::data::make_shared();

    XCTAssertEqual(data->reference(), -20);
}

- (void)test_restore_reference {
    [self setUserDefaultsReference:-10];

    auto const data = vu::data::make_shared();

    XCTAssertEqual(data->reference(), -10);
}

- (void)test_set_reference_from_user_defaults {
    auto const data = vu::data::make_shared();

    XCTAssertEqual(data->reference(), -20);

    [self setUserDefaultsReference:0];

    XCTAssertEqual(data->reference(), 0);

    [self setUserDefaultsReference:1];

    XCTAssertEqual(data->reference(), 0);

    [self setUserDefaultsReference:-30];

    XCTAssertEqual(data->reference(), -30);

    [self setUserDefaultsReference:-31];

    XCTAssertEqual(data->reference(), -30);
}

#pragma mark - private

- (void)clearUserDefaults {
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:[[NSBundle mainBundle] bundleIdentifier]];
}

- (void)setUserDefaultsReference:(int32_t)reference {
    [[NSUserDefaults standardUserDefaults] setValue:@(reference) forKey:@"reference"];
}

@end
