//
//  vu_indicator_tests.mm
//

#import <XCTest/XCTest.h>
#import "vu_indicator.hpp"
#import "vu_indicator_value.hpp"

using namespace yas;
using namespace yas::vu;

namespace yas::vu::test_utils {
struct settings : settings_for_indicator {
    int32_t reference_value = 0;

    int32_t reference() const override {
        return reference_value;
    }
};
}

@interface vu_indicator_tests : XCTestCase

@end

@implementation vu_indicator_tests

- (void)test_value {
    auto settings = std::make_shared<test_utils::settings>();
    auto const value = indicator_value::make_shared();
    auto const indicator = indicator::make_shared(value, settings);

    settings->reference_value = 0;
    value->store(1.0);

    XCTAssertEqualWithAccuracy(indicator->value(), 1.0, 0.001);

    settings->reference_value = -20;
    value->store(0.1);

    XCTAssertEqualWithAccuracy(indicator->value(), 1.0, 0.001);

    settings = nullptr;

    XCTAssertEqual(indicator->value(), 0.0);
}

@end
