//
//  vu_data.mm
//

#include "vu_data.hpp"
#import <Foundation/Foundation.h>

using namespace yas;

namespace yas::vu {
static NSString *const reference_key = @"reference";
static int32_t const reference_max = 0;
static int32_t const reference_min = -30;
}

struct vu::data::impl : base::impl {
    impl() {
        [[NSUserDefaults standardUserDefaults] registerDefaults:@{ vu::reference_key: @(-18) }];
    }

    vu::data::subject_t _subject;
};

vu::data::data() : base(std::make_shared<impl>()) {
}

vu::data::data(std::nullptr_t) : base(nullptr) {
}

void vu::data::set_reference(int32_t const ref) {
    if (ref != this->reference() && reference_min <= ref && ref <= reference_max) {
        [[NSUserDefaults standardUserDefaults] setInteger:ref forKey:vu::reference_key];
        [[NSUserDefaults standardUserDefaults] synchronize];

        this->subject().notify(vu::data::method::reference_changed, *this);
    }
}

void vu::data::increment_reference() {
    this->set_reference(this->reference() + 1);
}

void vu::data::decrement_reference() {
    this->set_reference(this->reference() - 1);
}

int32_t vu::data::reference() const {
    return static_cast<int32_t>([[NSUserDefaults standardUserDefaults] integerForKey:vu::reference_key]);
}

vu::data::subject_t &vu::data::subject() {
    return impl_ptr<impl>()->_subject;
}
