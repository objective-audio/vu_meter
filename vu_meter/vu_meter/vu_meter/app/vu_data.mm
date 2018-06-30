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
    flow::property<int32_t> _reference{0};
    flow::property<bool> _is_reference_max{false};
    flow::property<bool> _is_reference_min{false};
    flow::notifier<int32_t> _reference_setter;
    flow::notifier<std::nullptr_t> _reference_increment_sender;
    flow::notifier<std::nullptr_t> _reference_decrement_sender;
    std::vector<flow::observer> _flows;

    impl() {
        [[NSUserDefaults standardUserDefaults] registerDefaults:@{
            vu::reference_key: @(-20),
            vu::indicator_count_key: @(2)
        }];

        this->_reference.set_value(
            static_cast<int32_t>([[NSUserDefaults standardUserDefaults] integerForKey:vu::reference_key]));

        this->setup_flows();
    }

    void setup_flows() {
        // reference

        this->_flows.emplace_back(this->_reference.begin_flow()
                                      .perform([](int32_t const &value) {
                                          [[NSUserDefaults standardUserDefaults] setInteger:value
                                                                                     forKey:vu::reference_key];
                                          [[NSUserDefaults standardUserDefaults] synchronize];
                                      })
                                      .end());

        this->_flows.emplace_back(this->_reference_setter.begin_flow()
                                      .map([](int32_t const &value) {
                                          if (value < vu::reference_min) {
                                              return vu::reference_min;
                                          } else if (vu::reference_max < value) {
                                              return vu::reference_max;
                                          }
                                          return value;
                                      })
                                      .receive(this->_reference.receiver())
                                      .end());

        this->_flows.emplace_back(this->_reference.begin_flow()
                                      .map([](int32_t const &value) { return value == vu::reference_max; })
                                      .receive(this->_is_reference_max.receiver())
                                      .sync());

        this->_flows.emplace_back(this->_reference.begin_flow()
                                      .map([](int32_t const &value) { return value == vu::reference_min; })
                                      .receive(this->_is_reference_min.receiver())
                                      .sync());
    }

    void prepare() {
        auto weak_data = to_weak(cast<vu::data>());

        this->_flows.emplace_back(
            this->_reference_increment_sender.begin_flow()
                .filter([weak_data](std::nullptr_t const &) { return !!weak_data; })
                .map([weak_data](std::nullptr_t const &) { return weak_data.lock().reference().value() + 1; })
                .receive(this->_reference_setter.receiver())
                .end());

        this->_flows.emplace_back(
            this->_reference_decrement_sender.begin_flow()
                .filter([weak_data](std::nullptr_t const &) { return !!weak_data; })
                .map([weak_data](std::nullptr_t const &) { return weak_data.lock().reference().value() - 1; })
                .receive(this->_reference_setter.receiver())
                .end());
    }
};

vu::data::data() : base(std::make_shared<impl>()) {
    impl_ptr<impl>()->prepare();
}

vu::data::data(std::nullptr_t) : base(nullptr) {
}

flow::property<int32_t> &vu::data::reference() {
    return impl_ptr<impl>()->_reference;
}

flow::node_t<bool, true> vu::data::begin_is_reference_max_flow() const {
    return impl_ptr<impl>()->_is_reference_max.begin_flow();
}

flow::node_t<bool, true> vu::data::begin_is_reference_min_flow() const {
    return impl_ptr<impl>()->_is_reference_min.begin_flow();
}

flow::receiver<> &vu::data::reference_increment_receiver() {
    return impl_ptr<impl>()->_reference_increment_sender.receiver();
}

flow::receiver<> &vu::data::reference_decrement_receiver() {
    return impl_ptr<impl>()->_reference_decrement_sender.receiver();
}
