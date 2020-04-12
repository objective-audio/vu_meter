//
//  KVOObserverTests.m
//

#import <XCTest/XCTest.h>
#import "KVOObserver.h"

@interface TestObject : NSObject
@property (nonatomic, copy) NSString *value;
@end

@implementation TestObject
@end

@interface KVOObserverTests : XCTestCase

@end

@implementation KVOObserverTests

- (void)setUp {
}

- (void)tearDown {
}

- (void)test {
    __auto_type target = [[TestObject alloc] init];

    __auto_type received = [[NSMutableArray<NSString *> alloc] init];

    __auto_type observer =
        [[KVOObserver alloc] initWithTarget:target
                                    keyPath:@"value"
                                    handler:^(NSDictionary<NSKeyValueChangeKey, id> *_Nonnull change) {
                                        NSString *newValue = change[NSKeyValueChangeNewKey];
                                        [received addObject:newValue];
                                    }];

    XCTAssertEqual(received.count, 0);

    target.value = @"test_1";

    XCTAssertEqual(received.count, 1);
    XCTAssertEqualObjects(received[0], @"test_1");

    [observer release];
    
    target.value = @"test_2";

    XCTAssertEqual(received.count, 1);

    [received release];
    [target release];
}

@end
