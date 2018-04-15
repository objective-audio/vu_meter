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

        this->_reference.set_limiter([](int32_t const &value) {
            int32_t const min_limited = std::max(value, reference_min);
            int32_t const max_limited = std::min(min_limited, reference_max);
            return max_limited;
        });

        this->_reference.set_value(
            static_cast<int32_t>([[NSUserDefaults standardUserDefaults] integerForKey:vu::reference_key]));
    }

    void prepare(vu::data &data) {
        this->_reference_flow =
            this->_reference.begin_flow()
                .execute([weak_data = to_weak(data)](int32_t const &value) {
                    [[NSUserDefaults standardUserDefaults] setInteger:value forKey:vu::reference_key];
                    [[NSUserDefaults standardUserDefaults] synchronize];

                    if (auto data = weak_data.lock()) {
                        data.subject().notify(vu::data::method::reference_changed, data);
                    }
                })
                .end();
    }

    property<std::nullptr_t, int32_t> _reference;
    vu::data::subject_t _subject;
    base _reference_flow = nullptr;
};

vu::data::data() : base(std::make_shared<impl>()) {
    impl_ptr<impl>()->prepare(*this);
}

vu::data::data(std::nullptr_t) : base(nullptr) {
}

property<std::nullptr_t, int32_t> &vu::data::reference() {
    return impl_ptr<impl>()->_reference;
}

property<std::nullptr_t, int32_t> const &vu::data::reference() const {
    return impl_ptr<impl>()->_reference;
}

void vu::data::increment_reference() {
    this->reference().set_value(this->reference().value() + 1);
}

void vu::data::decrement_reference() {
    this->reference().set_value(this->reference().value() - 1);
}

vu::data::subject_t &vu::data::subject() {
    return impl_ptr<impl>()->_subject;
}
