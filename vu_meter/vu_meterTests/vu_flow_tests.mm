//
//  vu_flow_tests.mm
//

#import <XCTest/XCTest.h>
#import "yas_flow.h"

using namespace yas;

namespace vu::test {
struct receiver : base {
    struct impl : base::impl, flow::receivable<float>::impl {
        std::function<void(float const &)> handler;

        impl(std::function<void(float const &)> &&handler) : handler(std::move(handler)) {
        }

        void receive_value(float const &value) override {
            handler(value);
        }
    };

    receiver(std::function<void(float const &)> handler) : base(std::make_shared<impl>(std::move(handler))) {
    }

    receiver(std::nullptr_t) : base(nullptr) {
    }

    flow::receivable<float> receivable() {
        return flow::receivable<float>{impl_ptr<flow::receivable<float>::impl>()};
    }
};
}

@interface vu_flow_tests : XCTestCase

@end

@implementation vu_flow_tests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)test_receivable {
    float received = 0.0f;

    vu::test::receiver receiver{[&received](float const &value) { received = value; }};

    receiver.receivable().receive_value(2.0f);

    XCTAssertEqual(received, 2.0f);
}

- (void)test_receive {
    float received = 0.0f;

    vu::test::receiver receiver{[&received](float const &value) { received = value; }};

    flow::sender<float> sender;

    auto node = sender.begin_flow().receive(receiver.receivable()).end();

    sender.send_value(3.0f);

    XCTAssertEqual(received, 3.0f);
}

- (void)test_receive_by_end {
    float received = 0.0f;

    vu::test::receiver receiver{[&received](float const &value) { received = value; }};

    flow::sender<float> sender;

    auto node = sender.begin_flow().end(receiver.receivable());

    sender.send_value(4.0f);

    XCTAssertEqual(received, 4.0f);
}

@end
