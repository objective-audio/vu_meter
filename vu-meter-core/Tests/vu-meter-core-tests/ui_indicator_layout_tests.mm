//
//  vu_ui_indicator_layout_tests.mm
//

#import <XCTest/XCTest.h>
#import <vu-meter-core/ui/utils/ui_utils.hpp>

using namespace yas;
using namespace yas::vu;

@interface ui_indicator_layout_tests : XCTestCase

@end

@implementation ui_indicator_layout_tests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)test_zero {
    auto const regions = ui_utils::indicator_regions(0, ui::region{.origin = {10.0f, 20.0f}, .size = {100.0f, 50.0f}});

    XCTAssertEqual(regions.size(), 0);
}

- (void)test_just_one {
    // ---
    // |0|
    // ---

    auto const regions = ui_utils::indicator_regions(1, ui::region{.origin = {10.0f, 20.0f}, .size = {100.0f, 50.0f}});

    XCTAssertEqual(regions.size(), 1);

    XCTAssertEqualWithAccuracy(regions.at(0).origin.x, 10.0f, 0.1f);
    XCTAssertEqualWithAccuracy(regions.at(0).origin.y, 20.0f, 0.1f);
    XCTAssertEqualWithAccuracy(regions.at(0).size.width, 100.0f, 0.1f);
    XCTAssertEqualWithAccuracy(regions.at(0).size.height, 50.0f, 0.1f);
}

- (void)test_horizontal_just_two {
    // -----
    // |0|1|
    // -----

    auto const regions = ui_utils::indicator_regions(2, ui::region{.origin = {10.0f, 20.0f}, .size = {201.0f, 50.0f}});

    XCTAssertEqual(regions.size(), 2);

    XCTAssertEqualWithAccuracy(regions.at(0).origin.x, 10.0f, 0.1f);
    XCTAssertEqualWithAccuracy(regions.at(0).origin.y, 20.0f, 0.1f);
    XCTAssertEqualWithAccuracy(regions.at(0).size.width, 100.0f, 0.1f);
    XCTAssertEqualWithAccuracy(regions.at(0).size.height, 50.0f, 0.1f);

    XCTAssertEqualWithAccuracy(regions.at(1).origin.x, 111.0f, 0.1f);
    XCTAssertEqualWithAccuracy(regions.at(1).origin.y, 20.0f, 0.1f);
    XCTAssertEqualWithAccuracy(regions.at(1).size.width, 100.0f, 0.1f);
    XCTAssertEqualWithAccuracy(regions.at(1).size.height, 50.0f, 0.1f);
}

- (void)test_vertical_just_two {
    // ---
    // |0|
    // ---
    // |1|
    // ---

    auto const regions = ui_utils::indicator_regions(2, ui::region{.origin = {10.0f, 20.0f}, .size = {100.0f, 101.0f}});

    XCTAssertEqual(regions.size(), 2);

    XCTAssertEqualWithAccuracy(regions.at(0).origin.x, 10.0f, 0.1f);
    XCTAssertEqualWithAccuracy(regions.at(0).origin.y, 71.0f, 0.1f);
    XCTAssertEqualWithAccuracy(regions.at(0).size.width, 100.0f, 0.1f);
    XCTAssertEqualWithAccuracy(regions.at(0).size.height, 50.0f, 0.1f);

    XCTAssertEqualWithAccuracy(regions.at(1).origin.x, 10.0f, 0.1f);
    XCTAssertEqualWithAccuracy(regions.at(1).origin.y, 20.0f, 0.1f);
    XCTAssertEqualWithAccuracy(regions.at(1).size.width, 100.0f, 0.1f);
    XCTAssertEqualWithAccuracy(regions.at(1).size.height, 50.0f, 0.1f);
}

- (void)test_square_just_four {
    // -----
    // |0|1|
    // -----
    // |2|3|
    // -----

    auto const regions = ui_utils::indicator_regions(4, ui::region{.origin = {10.0f, 20.0f}, .size = {201.0f, 101.0f}});

    XCTAssertEqual(regions.size(), 4);

    XCTAssertEqualWithAccuracy(regions.at(0).origin.x, 10.0f, 0.1f);
    XCTAssertEqualWithAccuracy(regions.at(0).origin.y, 71.0f, 0.1f);
    XCTAssertEqualWithAccuracy(regions.at(0).size.width, 100.0f, 0.1f);
    XCTAssertEqualWithAccuracy(regions.at(0).size.height, 50.0f, 0.1f);

    XCTAssertEqualWithAccuracy(regions.at(1).origin.x, 111.0f, 0.1f);
    XCTAssertEqualWithAccuracy(regions.at(1).origin.y, 71.0f, 0.1f);
    XCTAssertEqualWithAccuracy(regions.at(1).size.width, 100.0f, 0.1f);
    XCTAssertEqualWithAccuracy(regions.at(1).size.height, 50.0f, 0.1f);

    XCTAssertEqualWithAccuracy(regions.at(2).origin.x, 10.0f, 0.1f);
    XCTAssertEqualWithAccuracy(regions.at(2).origin.y, 20.0f, 0.1f);
    XCTAssertEqualWithAccuracy(regions.at(2).size.width, 100.0f, 0.1f);
    XCTAssertEqualWithAccuracy(regions.at(2).size.height, 50.0f, 0.1f);

    XCTAssertEqualWithAccuracy(regions.at(3).origin.x, 111.0f, 0.1f);
    XCTAssertEqualWithAccuracy(regions.at(3).origin.y, 20.0f, 0.1f);
    XCTAssertEqualWithAccuracy(regions.at(3).size.width, 100.0f, 0.1f);
    XCTAssertEqualWithAccuracy(regions.at(3).size.height, 50.0f, 0.1f);
}

@end
