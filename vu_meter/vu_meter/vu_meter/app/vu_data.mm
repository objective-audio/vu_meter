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
    chaining::value::holder_ptr<int32_t> _reference = chaining::value::holder<int32_t>::make_shared(0);
    chaining::notifier_ptr<int32_t> _reference_setter = chaining::notifier<int32_t>::make_shared();

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

    chaining::observer_pool _pool;

    impl() {
        [[NSUserDefaults standardUserDefaults] registerDefaults:@{vu::reference_key: @(-20)}];

        this->_reference->set_value(
            static_cast<int32_t>([[NSUserDefaults standardUserDefaults] integerForKey:vu::reference_key]));

        this->setup_chainings();
    }

    void setup_chainings() {
        this->_pool += this->_reference_setter->chain()
                           .to([](int32_t const &value) {
                               if (value < vu::reference_min) {
                                   return vu::reference_min;
                               } else if (vu::reference_max < value) {
                                   return vu::reference_max;
                               }
                               return value;
                           })
                           .send_to(this->_reference)
                           .end();
    }
};

vu::data::data() : _impl(std::make_unique<impl>()) {
}

int32_t vu::data::reference() const {
    return this->_impl->_reference->raw();
}

vu::data_ptr vu::data::make_shared() {
    auto shared = std::shared_ptr<vu::data>(new vu::data{});

    return shared;
}
