//
//  vu_data.mm
//

#include "vu_data.hpp"
#import <Foundation/Foundation.h>
#include "vu_types.h"

using namespace yas;

namespace yas::vu {
static NSString *const reference_key = @"reference";
static NSString *const indicator_count_key = @"indicator_count";

static int32_t constexpr reference_max = 0;
static int32_t constexpr reference_min = -30;
}

struct vu::data::impl : base::impl {
    chaining::value::holder<int32_t> _reference{0};
    chaining::value::holder<bool> _is_reference_max{false};
    chaining::value::holder<bool> _is_reference_min{false};
    chaining::notifier<int32_t> _reference_setter;
    chaining::notifier<std::nullptr_t> _reference_increment_sender;
    chaining::notifier<std::nullptr_t> _reference_decrement_sender;
    chaining::observer_pool _pool;

    impl() {
        [[NSUserDefaults standardUserDefaults] registerDefaults:@{
            vu::reference_key: @(-20),
            vu::indicator_count_key: @(2)
        }];

        this->_reference.set_value(
            static_cast<int32_t>([[NSUserDefaults standardUserDefaults] integerForKey:vu::reference_key]));

        this->setup_chainings();
    }

    void setup_chainings() {
        // reference

        this->_pool += this->_reference.chain()
                           .perform([](int32_t const &value) {
                               [[NSUserDefaults standardUserDefaults] setInteger:value forKey:vu::reference_key];
                               [[NSUserDefaults standardUserDefaults] synchronize];
                           })
                           .end();

        this->_pool += this->_reference_setter.chain()
                           .to([](int32_t const &value) {
                               if (value < vu::reference_min) {
                                   return vu::reference_min;
                               } else if (vu::reference_max < value) {
                                   return vu::reference_max;
                               }
                               return value;
                           })
                           .receive(this->_reference.receiver())
                           .end();

        this->_pool += this->_reference.chain()
                           .to([](int32_t const &value) { return value == vu::reference_max; })
                           .receive(this->_is_reference_max.receiver())
                           .sync();

        this->_pool += this->_reference.chain()
                           .to([](int32_t const &value) { return value == vu::reference_min; })
                           .receive(this->_is_reference_min.receiver())
                           .sync();
    }

    void prepare() {
        auto weak_data = to_weak(cast<vu::data>());

        this->_pool += this->_reference_increment_sender.chain()
                           .guard([weak_data](std::nullptr_t const &) { return !!weak_data; })
                           .to([weak_data](std::nullptr_t const &) { return weak_data.lock().reference().raw() + 1; })
                           .receive(this->_reference_setter.receiver())
                           .end();

        this->_pool += this->_reference_decrement_sender.chain()
                           .guard([weak_data](std::nullptr_t const &) { return !!weak_data; })
                           .to([weak_data](std::nullptr_t const &) { return weak_data.lock().reference().raw() - 1; })
                           .receive(this->_reference_setter.receiver())
                           .end();
    }
};

vu::data::data() : base(std::make_shared<impl>()) {
    impl_ptr<impl>()->prepare();
}

vu::data::data(std::nullptr_t) : base(nullptr) {
}

chaining::value::holder<int32_t> &vu::data::reference() {
    return impl_ptr<impl>()->_reference;
}

chaining::chain_sync_t<bool> vu::data::is_reference_max_chain() const {
    return impl_ptr<impl>()->_is_reference_max.chain();
}

chaining::chain_sync_t<bool> vu::data::is_reference_min_chain() const {
    return impl_ptr<impl>()->_is_reference_min.chain();
}

chaining::receiver<> &vu::data::reference_increment_receiver() {
    return impl_ptr<impl>()->_reference_increment_sender.receiver();
}

chaining::receiver<> &vu::data::reference_decrement_receiver() {
    return impl_ptr<impl>()->_reference_decrement_sender.receiver();
}
