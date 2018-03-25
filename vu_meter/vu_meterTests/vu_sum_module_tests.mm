//
//  vu_sum_module_tests.mm
//

#import <XCTest/XCTest.h>
#import "vu_sum_module.hpp"
#import "yas_processing_test_utils.h"

using namespace yas;

@interface vu_sum_module_tests : XCTestCase

@end

@implementation vu_sum_module_tests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)test_process {
    proc::sample_rate_t const sample_rate = 8;
    double const duration = 1.0 / 4.0;
    proc::length_t const process_length = 2;

    //    auto stream = test::make_signal_stream(time::range{0, process_length}, left_data, time::range{1, 3}, 0,
    //                                           right_data,
    //                                           time::range{2, 3}, 1);

    auto module = vu::sum::make_signal_module(duration);
    //    length_t const process_length = 6;
    //
    //    int16_t const left_data[3] = {
    //        1, 2, 3,
    //    };
    //
    //    int16_t const right_data[3] = {
    //        2, 2, 2,
    //    };
    //

    //
    //    auto module = make_signal_module<int16_t>(compare::kind::is_equal);
    //    connect(module, compare::input::left, 0);
    //    connect(module, compare::input::right, 1);
    //    connect(module, compare::output::result, 2);
    //
    //    module.process({0, process_length}, stream);
    //
    //    XCTAssertTrue(stream.has_channel(2));
    //
    //    auto const &events = stream.channel(2).events();
    //
    //    XCTAssertEqual(events.size(), 1);
    //
    //    auto const signal = cast<signal_event>(events.cbegin()->second);
    //    auto const &vec = signal.vector<boolean>();
    //
    //    XCTAssertEqual(vec.size(), process_length);
    //    XCTAssertTrue(vec[0]);   // 0 == 0
    //    XCTAssertFalse(vec[1]);  // 1 == 0
    //    XCTAssertTrue(vec[2]);   // 2 == 2
    //    XCTAssertFalse(vec[3]);  // 3 == 2
    //    XCTAssertFalse(vec[4]);  // 0 == 2
    //    XCTAssertTrue(vec[5]);   // 0 == 0
}

@end
