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
    property<int32_t> _reference;
    flow::sender<int32_t> _reference_setter;
    flow::receiver<> _ref_inc_receiver = nullptr;
    flow::receiver<> _ref_dec_receiver = nullptr;
    vu::data::subject_t _subject;
    base _reference_flow = nullptr;
    base _reference_setter_flow = nullptr;

    impl() {
        [[NSUserDefaults standardUserDefaults] registerDefaults:@{ vu::reference_key: @(-20) }];

        this->_reference.set_value(
            static_cast<int32_t>([[NSUserDefaults standardUserDefaults] integerForKey:vu::reference_key]));

        this->_reference_flow =
            this->_reference.begin_value_flow()
                .guard([](int32_t const &value) { return reference_min <= value && value <= reference_max; })
                .perform([](int32_t const &value) {
                    [[NSUserDefaults standardUserDefaults] setInteger:value forKey:vu::reference_key];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                })
                .end();

        this->_reference_setter_flow = this->_reference_setter.begin()
                                           .to<int32_t>([](int32_t const &value) {
                                               if (value < vu::reference_min) {
                                                   return vu::reference_min;
                                               } else if (vu::reference_max < value) {
                                                   return vu::reference_max;
                                               }
                                               return value;
                                           })
                                           .end(this->_reference.receiver());
    }

    void prepare() {
        auto weak_data = to_weak(cast<vu::data>());

        this->_ref_inc_receiver = flow::receiver<>([weak_data](auto const &) {
            if (auto data = weak_data.lock()) {
                auto data_impl = data.impl_ptr<impl>();
                data_impl->_reference_setter.send_value(data_impl->_reference.value() + 1);
            }
        });

        this->_ref_dec_receiver = flow::receiver<>([weak_data](auto const &) {
            if (auto data = weak_data.lock()) {
                auto data_impl = data.impl_ptr<impl>();
                data_impl->_reference_setter.send_value(data_impl->_reference.value() - 1);
            }
        });
    }
};

vu::data::data() : base(std::make_shared<impl>()) {
    impl_ptr<impl>()->prepare();
}

vu::data::data(std::nullptr_t) : base(nullptr) {
}

flow::node<int32_t> vu::data::begin_reference_flow() const {
    return impl_ptr<impl>()->_reference.begin_value_flow();
}

flow::receiver<> &vu::data::reference_increment_receiver() {
    return impl_ptr<impl>()->_ref_inc_receiver;
}

flow::receiver<> &vu::data::reference_decrement_receiver() {
    return impl_ptr<impl>()->_ref_dec_receiver;
}

void vu::data::set_reference(int32_t const value) {
    impl_ptr<impl>()->_reference_setter.send_value(value);
}

property<int32_t> const &vu::data::reference() const {
    return impl_ptr<impl>()->_reference;
}

void vu::data::increment_reference() {
    this->set_reference(this->reference().value() + 1);
}

void vu::data::decrement_reference() {
    this->set_reference(this->reference().value() - 1);
}
