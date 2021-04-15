//
//  vu_data.mm
//

#include "vu_data.hpp"
#import <Foundation/Foundation.h>
#include <cpp_utils/yas_cf_utils.h>
#include <cpp_utils/yas_objc_ptr.h>
#import "KVOObserver.h"
#include "vu_types.h"

#include <iostream>

using namespace yas;

namespace yas::vu {
static NSString *const reference_key = @"reference";

static int32_t constexpr reference_max = 0;
static int32_t constexpr reference_min = -30;
}

struct vu::data::impl {
    observing::value::holder_ptr<int32_t> _reference = observing::value::holder<int32_t>::make_shared(0);
    observing::notifier_ptr<int32_t> _reference_setter = observing::notifier<int32_t>::make_shared();

    objc_ptr<KVOObserver *> _reference_observer = objc_ptr_with_move_object([[KVOObserver alloc]
        initWithTarget:[NSUserDefaults standardUserDefaults]
               keyPath:vu::reference_key
               handler:[weak_setter = to_weak(this->_reference_setter)](NSDictionary<NSKeyValueChangeKey, id> *change) {
                   if (auto setter = weak_setter.lock()) {
                       double const value = [[NSUserDefaults standardUserDefaults] doubleForKey:vu::reference_key];
                       std::cout << "value : " << value << std::endl;
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

vu::data::data() : _impl(std::make_unique<impl>()) {
}

int32_t vu::data::reference() const {
    return this->_impl->_reference->value();
}

vu::data_ptr vu::data::make_shared() {
    auto shared = std::shared_ptr<vu::data>(new vu::data{});

    return shared;
}
