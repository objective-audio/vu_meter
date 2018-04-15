//
//  vu_observing_tests.mm
//

#import <XCTest/XCTest.h>
#import "yas_observing.h"
#import <string>

using namespace yas;

@interface vu_observing_tests : XCTestCase

@end

@implementation vu_observing_tests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)test_object {
    subject<std::string, int> subject;

    subject.set_object_handler([](std::string const &key) { return std::stoi(key); });

    XCTAssertEqual(subject.object("2"), 2);
}

- (void)test_value_observer {
    subject<std::string, int> subject;

    int notified = -1;

    auto observer = subject.make_value_observer("test_key", [&notified](int const &value) { notified = value; });

    subject.notify("test_key", 2);

    XCTAssertEqual(notified, 2);
}

@end
