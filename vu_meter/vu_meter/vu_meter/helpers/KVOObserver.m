//
//  KVOObserver.m
//

#import "KVOObserver.h"
#import <objc_utils/yas_objc_macros.h>

@interface KVOObserver ()
@property (nonatomic, weak) NSObject *target;
@property (nonatomic, copy) NSString *keyPath;
@property (nonatomic, copy) void (^handler)(NSDictionary<NSKeyValueChangeKey, id> *);
@end

@implementation KVOObserver

- (instancetype)initWithTarget:(NSObject *)target
                       keyPath:(NSString *)keyPath
                       handler:(void (^)(NSDictionary<NSKeyValueChangeKey, id> *))handler {
    self = [super init];
    if (self) {
        self.target = target;
        self.keyPath = keyPath;
        self.handler = handler;

        [target addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)dealloc {
    [_target removeObserver:self forKeyPath:_keyPath];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey, id> *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:self.keyPath]) {
        self.handler(change);
    }
}

@end
