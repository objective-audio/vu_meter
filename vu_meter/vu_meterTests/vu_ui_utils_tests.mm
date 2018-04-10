//
//  vu_ui_utils_tests.mm
//

#import <XCTest/XCTest.h>
#import "vu_ui_utils.hpp"
#import "yas_audio.h"

using namespace yas;

@interface vu_ui_utils_tests : XCTestCase

@end

@implementation vu_ui_utils_tests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)test_meter_angle {
    XCTAssertEqualWithAccuracy(vu::ui_utils::meter_angle(audio::math::linear_from_decibel(-20.0f), 0.0f, 50.0f).degrees,
                               50.0f, 0.001f);
    XCTAssertEqualWithAccuracy(vu::ui_utils::meter_angle(audio::math::linear_from_decibel(3.0f), 0.0f, 50.0f).degrees,
                               -50.0f, 0.001f);

    XCTAssertEqualWithAccuracy(
        vu::ui_utils::meter_angle(audio::math::linear_from_decibel(-40.0f), -20.0f, 50.0f).degrees, 50.0f, 0.001f);
    XCTAssertEqualWithAccuracy(
        vu::ui_utils::meter_angle(audio::math::linear_from_decibel(-17.0f), -20.0f, 50.0f).degrees, -50.0f, 0.001f);
}

- (void)test_gridline_y {
    XCTAssertEqualWithAccuracy(
        vu::ui_utils::gridline_y(ui::angle{.degrees = 0.0f}, ui::angle{.degrees = 50.0f}, 2.0f, 0.0f), 2.0f, 0.001f);
    XCTAssertEqualWithAccuracy(
        vu::ui_utils::gridline_y(ui::angle{.degrees = -50.0f}, ui::angle{.degrees = 50.0f}, 2.0f, 1.0f), 2.0f, 0.001f);
    XCTAssertEqualWithAccuracy(
        vu::ui_utils::gridline_y(ui::angle{.degrees = 50.0f}, ui::angle{.degrees = 50.0f}, 2.0f, 1.0f), 2.0f, 0.001f);

    XCTAssertEqualWithAccuracy(
        vu::ui_utils::gridline_y(ui::angle{.degrees = 0.0f}, ui::angle{.degrees = 45.0f}, 1.0f, 1.0f),
        1.0f / std::sqrt(2.0f), 0.001f);
}

@end
