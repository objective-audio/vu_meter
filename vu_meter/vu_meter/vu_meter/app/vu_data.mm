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

struct vu::data::impl {
    chaining::value::holder_ptr<int32_t> _reference = chaining::value::holder<int32_t>::make_shared(0);
    chaining::value::holder_ptr<bool> _is_reference_max = chaining::value::holder<bool>::make_shared(false);
    chaining::value::holder_ptr<bool> _is_reference_min = chaining::value::holder<bool>::make_shared(false);
    chaining::notifier_ptr<int32_t> _reference_setter = chaining::notifier<int32_t>::make_shared();
    chaining::notifier_ptr<std::nullptr_t> _reference_increment_sender =
        chaining::notifier<std::nullptr_t>::make_shared();
    chaining::notifier_ptr<std::nullptr_t> _reference_decrement_sender =
        chaining::notifier<std::nullptr_t>::make_shared();
    chaining::observer_pool _pool;

    impl() {
        [[NSUserDefaults standardUserDefaults] registerDefaults:@{
            vu::reference_key: @(-20),
            vu::indicator_count_key: @(2)
        }];

        this->_reference->set_value(
            static_cast<int32_t>([[NSUserDefaults standardUserDefaults] integerForKey:vu::reference_key]));

        this->setup_chainings();
    }

    void setup_chainings() {
        // reference

        this->_pool += this->_reference->chain()
                           .perform([](int32_t const &value) {
                               [[NSUserDefaults standardUserDefaults] setInteger:value forKey:vu::reference_key];
                               [[NSUserDefaults standardUserDefaults] synchronize];
                           })
                           .end();

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

        this->_pool += this->_reference->chain()
                           .to([](int32_t const &value) { return value == vu::reference_max; })
                           .send_to(this->_is_reference_max)
                           .sync();

        this->_pool += this->_reference->chain()
                           .to([](int32_t const &value) { return value == vu::reference_min; })
                           .send_to(this->_is_reference_min)
                           .sync();
    }

    void prepare(data_ptr const &data) {
        auto weak_data = to_weak(data);

        this->_pool += this->_reference_increment_sender->chain()
                           .guard([weak_data](std::nullptr_t const &) { return !weak_data.expired(); })
                           .to([weak_data](std::nullptr_t const &) { return weak_data.lock()->reference()->raw() + 1; })
                           .send_to(this->_reference_setter)
                           .end();

        this->_pool += this->_reference_decrement_sender->chain()
                           .guard([weak_data](std::nullptr_t const &) { return !weak_data.expired(); })
                           .to([weak_data](std::nullptr_t const &) { return weak_data.lock()->reference()->raw() - 1; })
                           .send_to(this->_reference_setter)
                           .end();
    }
};

vu::data::data() : _impl(std::make_unique<impl>()) {
}

chaining::value::holder_ptr<int32_t> const &vu::data::reference() {
    return this->_impl->_reference;
}

chaining::chain_sync_t<bool> vu::data::is_reference_max_chain() const {
    return this->_impl->_is_reference_max->chain();
}

chaining::chain_sync_t<bool> vu::data::is_reference_min_chain() const {
    return this->_impl->_is_reference_min->chain();
}

chaining::receiver_ptr<std::nullptr_t> vu::data::reference_increment_receiver() {
    return this->_impl->_reference_increment_sender;
}

chaining::receiver_ptr<std::nullptr_t> vu::data::reference_decrement_receiver() {
    return this->_impl->_reference_decrement_sender;
}

void vu::data::_prepare(data_ptr const &shared) {
    this->_impl->prepare(shared);
}

vu::data_ptr vu::data::make_shared() {
    auto shared = std::shared_ptr<vu::data>(new vu::data{});

    return shared;
}
