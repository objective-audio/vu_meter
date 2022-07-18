//
//  KVOObserver.h
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KVOObserver : NSObject

- (instancetype)initWithTarget:(NSObject *)target
                       keyPath:(NSString *)keyPath
                       handler:(void (^)(NSDictionary<NSKeyValueChangeKey, id> *))handler;

@end

NS_ASSUME_NONNULL_END
