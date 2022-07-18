//
//  vu_settings.mm
//

#include "vu_settings.hpp"
#import <Foundation/Foundation.h>
#include <cpp_utils/yas_cf_utils.h>
#include <cpp_utils/yas_objc_ptr.h>
#import "KVOObserver.h"

using namespace yas;

namespace yas::vu {
static NSString *const reference_key = @"reference";

static int32_t constexpr reference_max = 0;
static int32_t constexpr reference_min = -30;
}

struct vu::settings::impl {
    observing::value::holder_ptr<int32_t> _reference = observing::value::holder<int32_t>::make_shared(0);
    observing::notifier_ptr<int32_t> _reference_setter = observing::notifier<int32_t>::make_shared();

    objc_ptr<KVOObserver *> _reference_observer = objc_ptr_with_move_object([[KVOObserver alloc]
        initWithTarget:[NSUserDefaults standardUserDefaults]
               keyPath:vu::reference_key
               handler:[weak_setter = to_weak(this->_reference_setter)](NSDictionary<NSKeyValueChangeKey, id> *change) {
                   if (auto setter = weak_setter.lock()) {
                       double const value = [[NSUserDefaults standardUserDefaults] doubleForKey:vu::reference_key];
                       setter->notify(value);
                   }
               }]);

    observing::canceller_pool _pool;

    impl() {
        [[NSUserDefaults standardUserDefaults] registerDefaults:@{vu::reference_key: @(-20)}];

        this->_reference->set_value(
            static_cast<int32_t>([[NSUserDefaults standardUserDefaults] integerForKey:vu::reference_key]));

        this->setup_observing();
    }

    void setup_observing() {
        this->_reference_setter
            ->observe([this](int32_t const &value) {
                if (value < vu::reference_min) {
                    this->_reference->set_value(vu::reference_min);
                } else if (vu::reference_max < value) {
                    this->_reference->set_value(vu::reference_max);
                } else {
                    this->_reference->set_value(value);
                }
            })
            .end()
            ->add_to(this->_pool);
    }
};

vu::settings::settings() : _impl(std::make_unique<impl>()) {
}

int32_t vu::settings::reference() const {
    return this->_impl->_reference->value();
}

std::shared_ptr<vu::settings> vu::settings::make_shared() {
    return std::shared_ptr<vu::settings>(new vu::settings{});
}
