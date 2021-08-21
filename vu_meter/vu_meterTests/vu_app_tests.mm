//
//  vu_app_tests.mm
//

#import <XCTest/XCTest.h>
#import "vu_app.h"

using namespace yas;
using namespace yas::vu;

@interface vu_app_tests : XCTestCase

@end

@implementation vu_app_tests

- (void)test_make_shared {
    auto const app = app::make_shared();

    XCTAssertEqual(app->ui_standard(), nullptr);
}

@end
