//
//  vu_summing_buffer_tests.mm
//

#import <XCTest/XCTest.h>
#import "vu_summing_buffer.hpp"

using namespace yas;

@interface vu_summing_buffer_tests : XCTestCase

@end

@implementation vu_summing_buffer_tests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)test_create {
    vu::summing_buffer buffer{};

    XCTAssertEqual(buffer.pushed.size(), 0);
    XCTAssertEqual(buffer.stored.size(), 0);
    XCTAssertEqual(buffer.pos, 0);
}

- (void)test_setup {
    vu::summing_buffer buffer{};
    proc::time::range time_range{0, 2};

    buffer.setup(time_range, 4);

    XCTAssertEqual(buffer.pushed.size(), 0);
    XCTAssertEqual(buffer.stored.size(), 4);
    XCTAssertEqual(buffer.pos, 0);
}

- (void)test_push {
    vu::summing_buffer buffer{};
    proc::time::range time_range{0, 2};
    buffer.setup(time_range, 4);

    std::vector<float> vec{1.0f, 2.0f};

    buffer.push(vec.data(), 2);

    XCTAssertEqual(buffer.pushed.size(), 2);
    XCTAssertEqual(buffer.pushed.at(0), 1.0f);
    XCTAssertEqual(buffer.pushed.at(1), 2.0f);
    XCTAssertEqual(buffer.stored.size(), 4);
    XCTAssertEqual(buffer.pos, 0);
}

- (void)test_fetch_sum {
    vu::summing_buffer buffer{};
    proc::time::range time_range{0, 2};
    buffer.setup(time_range, 4);
    std::vector<float> push_vec{1.0f, 2.0f};
    buffer.push(push_vec.data(), 2);

    std::vector<float> fetch_vec{0.0f, 0.0f};

    buffer.fetch_sum(fetch_vec.data(), 2);

    XCTAssertEqual(fetch_vec.at(0), 1.0f);
    XCTAssertEqual(fetch_vec.at(1), 3.0f);

    XCTAssertEqual(buffer.pos, 0);
}

- (void)test_divide {
    std::vector<float> vec{1.0f, 2.0f, 4.0f, 8.0f};

    vu::summing_buffer::divide(vec.data(), 4, 4.0f);

    XCTAssertEqual(vec.at(0), 0.25f);
    XCTAssertEqual(vec.at(1), 0.5f);
    XCTAssertEqual(vec.at(2), 1.0f);
    XCTAssertEqual(vec.at(3), 2.0f);
}

- (void)test_finalize {
    vu::summing_buffer buffer{};
    proc::time::range time_range{0, 2};
    buffer.setup(time_range, 4);
    std::vector<float> push_vec{1.0f, 2.0f};
    buffer.push(push_vec.data(), 2);

    buffer.finalize();

    XCTAssertEqual(buffer.stored.at(0), 1.0f);
    XCTAssertEqual(buffer.stored.at(1), 2.0f);
    XCTAssertEqual(buffer.stored.at(2), 0.0f);
    XCTAssertEqual(buffer.stored.at(3), 0.0f);

    XCTAssertEqual(buffer.pushed.size(), 0);
    XCTAssertEqual(buffer.pos, 2);
}

- (void)test_execute_several_times {
    vu::summing_buffer buffer{};

    {
        proc::time::range time_range{0, 2};
        buffer.setup(time_range, 3);
        std::vector<float> push_vec{1.0f, 2.0f};
        buffer.push(push_vec.data(), 2);

        std::vector<float> fetch_vec{0.0f, 0.0f};
        buffer.fetch_sum(fetch_vec.data(), 2);

        XCTAssertEqual(fetch_vec.at(0), 1.0f);
        XCTAssertEqual(fetch_vec.at(1), 3.0f);

        buffer.finalize();
    }

    XCTAssertEqual(buffer.pos, 2);
    XCTAssertEqual(buffer.stored.at(0), 1.0f);
    XCTAssertEqual(buffer.stored.at(1), 2.0f);
    XCTAssertEqual(buffer.stored.at(2), 0.0f);

    {
        proc::time::range time_range{2, 2};
        buffer.setup(time_range, 3);

        std::vector<float> push_vec{3.0f, 4.0f};
        buffer.push(push_vec.data(), 2);

        std::vector<float> fetch_vec{0.0f, 0.0f};
        buffer.fetch_sum(fetch_vec.data(), 2);

        XCTAssertEqual(fetch_vec.at(0), 6.0f);
        XCTAssertEqual(fetch_vec.at(1), 9.0f);

        buffer.finalize();
    }

    XCTAssertEqual(buffer.pos, 1);
    XCTAssertEqual(buffer.stored.at(0), 4.0f);
    XCTAssertEqual(buffer.stored.at(1), 2.0f);
    XCTAssertEqual(buffer.stored.at(2), 3.0f);

    {
        proc::time::range time_range{4, 2};
        buffer.setup(time_range, 3);
        std::vector<float> push_vec{5.0f, 6.0f};
        buffer.push(push_vec.data(), 2);

        std::vector<float> fetch_vec{0.0f, 0.0f};
        buffer.fetch_sum(fetch_vec.data(), 2);

        XCTAssertEqual(fetch_vec.at(0), 12.0f);
        XCTAssertEqual(fetch_vec.at(1), 15.0f);

        buffer.finalize();
    }

    XCTAssertEqual(buffer.pos, 0);
    XCTAssertEqual(buffer.stored.at(0), 4.0f);
    XCTAssertEqual(buffer.stored.at(1), 5.0f);
    XCTAssertEqual(buffer.stored.at(2), 6.0f);
}

- (void)test_setup_reset_by_time_range {
    vu::summing_buffer buffer{};

    {
        proc::time::range time_range{0, 2};
        buffer.setup(time_range, 4);
        std::vector<float> push_vec{1.0f, 2.0f};
        buffer.push(push_vec.data(), 2);
        buffer.finalize();
    }

    {
        proc::time::range time_range{3, 2};
        buffer.setup(time_range, 4);

        XCTAssertEqual(buffer.stored.at(0), 0.0f);
        XCTAssertEqual(buffer.stored.at(1), 0.0f);
        XCTAssertEqual(buffer.stored.at(2), 0.0f);
        XCTAssertEqual(buffer.stored.at(3), 0.0f);
    }
}

- (void)test_setup_reset_by_length {
    vu::summing_buffer buffer{};

    {
        proc::time::range time_range{0, 2};
        buffer.setup(time_range, 4);
        std::vector<float> push_vec{1.0f, 2.0f};
        buffer.push(push_vec.data(), 2);
        buffer.finalize();
    }

    {
        proc::time::range time_range{2, 2};
        buffer.setup(time_range, 3);

        XCTAssertEqual(buffer.stored.size(), 3);
        XCTAssertEqual(buffer.stored.at(0), 0.0f);
        XCTAssertEqual(buffer.stored.at(1), 0.0f);
        XCTAssertEqual(buffer.stored.at(2), 0.0f);
    }
}

@end
