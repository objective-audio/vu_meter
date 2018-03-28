//
//  vu_data.mm
//

#include "vu_data.hpp"
#import <Foundation/Foundation.h>

using namespace yas;

namespace yas::vu {
static NSString *const reference_key = @"reference";
}

vu::data::data() {
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{ vu::reference_key: @(-18) }];
}

void vu::data::set_reference(int32_t const ref) {
    [[NSUserDefaults standardUserDefaults] setInteger:ref forKey:vu::reference_key];
}

int32_t vu::data::reference() const {
    return static_cast<int32_t>([[NSUserDefaults standardUserDefaults] integerForKey:vu::reference_key]);
}
