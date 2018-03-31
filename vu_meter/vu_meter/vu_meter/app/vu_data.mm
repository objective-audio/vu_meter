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
    if (ref != this->reference()) {
        [[NSUserDefaults standardUserDefaults] setInteger:ref forKey:vu::reference_key];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        this->subject.notify(vu::data::method::reference_changed, *this);
    }
}

int32_t vu::data::reference() const {
    return static_cast<int32_t>([[NSUserDefaults standardUserDefaults] integerForKey:vu::reference_key]);
}
