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
    double const duration = 0.5;
    proc::length_t const process_length = 2;

    auto module = vu::sum::make_signal_module(duration);
    connect(module, vu::sum::input::value, 0);
    connect(module, vu::sum::output::value, 0);

    auto make_stream = [sample_rate](time::range time_range, float data0, float data1) {
        proc::stream stream{sync_source{sample_rate, time_range.length}};

        auto &channel = stream.add_channel(0);
        proc::signal_event_ptr phase_signal = proc::signal_event::make_shared<float>(process_length);
        float *phase_data = phase_signal->data<float>();
        phase_data[0] = data0;
        phase_data[1] = data1;
        channel.insert_event(proc::time{time_range}, std::move(phase_signal));

        return stream;
    };

    {
        time::range time_range{0, process_length};
        auto stream = make_stream(time_range, 1.0f, 2.0f);

        module->process(time_range, stream);

        XCTAssertTrue(stream.has_channel(0));

        auto const &events = stream.channel(0).events();

        XCTAssertEqual(events.size(), 1);

        proc::signal_event_ptr const signal = std::dynamic_pointer_cast<proc::signal_event>(events.cbegin()->second);
        auto const &vec = signal->vector<float>();

        XCTAssertEqual(vec.size(), process_length);

        XCTAssertEqual(vec.at(0), 0.25f);
        XCTAssertEqual(vec.at(1), 0.75f);
    }

    {
        time::range time_range{process_length, process_length};
        auto stream = make_stream(time_range, 3.0f, 4.0f);

        module->process(time_range, stream);

        XCTAssertTrue(stream.has_channel(0));

        auto const &events = stream.channel(0).events();

        XCTAssertEqual(events.size(), 1);

        proc::signal_event_ptr const signal = std::dynamic_pointer_cast<proc::signal_event>(events.cbegin()->second);
        auto const &vec = signal->vector<float>();

        XCTAssertEqual(vec.size(), process_length);

        XCTAssertEqual(vec.at(0), 1.5f);
        XCTAssertEqual(vec.at(1), 2.5f);
    }

    {
        time::range time_range{process_length * 2, process_length};
        auto stream = make_stream(time_range, 5.0f, 6.0f);

        module->process(time_range, stream);

        XCTAssertTrue(stream.has_channel(0));

        auto const &events = stream.channel(0).events();

        XCTAssertEqual(events.size(), 1);

        proc::signal_event_ptr const signal = std::dynamic_pointer_cast<proc::signal_event>(events.cbegin()->second);
        auto const &vec = signal->vector<float>();

        XCTAssertEqual(vec.size(), process_length);

        XCTAssertEqual(vec.at(0), 3.5f);
        XCTAssertEqual(vec.at(1), 4.5f);
    }
}

@end
