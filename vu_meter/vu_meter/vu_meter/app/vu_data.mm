//
//  vu_data.mm
//

#include "vu_data.hpp"
#import <Foundation/Foundation.h>

using namespace yas;

namespace yas::vu {
static NSString *const reference_key = @"reference";
static NSString *const indicator_count_key = @"indicator_count";

static int32_t constexpr reference_max = 0;
static int32_t constexpr reference_min = -30;
static uint32_t constexpr indicator_count_max = 8;
static uint32_t constexpr indicator_count_min = 1;
}

struct vu::data::impl : base::impl {
    property<int32_t> _reference;
    property<uint32_t> _indicator_count;
    flow::sender<int32_t> _reference_setter;
    flow::sender<uint32_t> _indicator_count_setter;
    flow::sender<std::nullptr_t> _ref_inc_sender;
    flow::sender<std::nullptr_t> _ref_dec_sender;
    flow::sender<std::nullptr_t> _ind_inc_sender;
    flow::sender<std::nullptr_t> _ind_dec_sender;
    vu::data::subject_t _subject;
    std::vector<flow::observer> _flows;

    impl() {
        [[NSUserDefaults standardUserDefaults] registerDefaults:@{
            vu::reference_key: @(-20),
            vu::indicator_count_key: @(2)
        }];

        this->_reference.set_value(
            static_cast<int32_t>([[NSUserDefaults standardUserDefaults] integerForKey:vu::reference_key]));
        this->_indicator_count.set_value(
            static_cast<uint32_t>([[NSUserDefaults standardUserDefaults] integerForKey:vu::indicator_count_key]));

        this->setup_flows();
    }

    void setup_flows() {
        // reference

        this->_flows.emplace_back(this->_reference.begin_value_flow()
                                      .perform([](int32_t const &value) {
                                          [[NSUserDefaults standardUserDefaults] setInteger:value
                                                                                     forKey:vu::reference_key];
                                          [[NSUserDefaults standardUserDefaults] synchronize];
                                      })
                                      .end());

        this->_flows.emplace_back(this->_reference_setter.begin()
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

        // indicator_count

        this->_flows.emplace_back(this->_indicator_count.begin_value_flow()
                                      .perform([](uint32_t const &value) {
                                          [[NSUserDefaults standardUserDefaults] setInteger:value
                                                                                     forKey:vu::reference_key];
                                          [[NSUserDefaults standardUserDefaults] synchronize];
                                      })
                                      .end());

        this->_flows.emplace_back(this->_indicator_count_setter.begin()
                                      .map([](uint32_t const &value) {
                                          if (value < vu::indicator_count_min) {
                                              return vu::indicator_count_min;
                                          } else if (vu::indicator_count_max < value) {
                                              return vu::indicator_count_max;
                                          }
                                          return value;
                                      })
                                      .receive(this->_indicator_count.receiver())
                                      .end());
    }

    void prepare() {
        auto weak_data = to_weak(cast<vu::data>());

        this->_flows.emplace_back(
            this->_ref_inc_sender.begin()
                .filter([weak_data](std::nullptr_t const &) { return !!weak_data; })
                .map([weak_data](std::nullptr_t const &) { return weak_data.lock().reference() + 1; })
                .receive(this->_reference_setter.receiver())
                .end());

        this->_flows.emplace_back(
            this->_ref_dec_sender.begin()
                .filter([weak_data](std::nullptr_t const &) { return !!weak_data; })
                .map([weak_data](std::nullptr_t const &) { return weak_data.lock().reference() - 1; })
                .receive(this->_reference_setter.receiver())
                .end());

        this->_flows.emplace_back(
            this->_ind_inc_sender.begin()
                .filter([weak_data](auto const &) { return !!weak_data; })
                .map([weak_data](std::nullptr_t const &) { return weak_data.lock().indicator_count() + 1; })
                .receive(this->_indicator_count_setter.receiver())
                .end());

        this->_flows.emplace_back(
            this->_ind_dec_sender.begin()
                .filter([weak_data](auto const &) { return !!weak_data; })
                .map([weak_data](std::nullptr_t const &) { return weak_data.lock().indicator_count() - 1; })
                .receive(this->_indicator_count_setter.receiver())
                .end());
    }
};

vu::data::data() : base(std::make_shared<impl>()) {
    impl_ptr<impl>()->prepare();
}

vu::data::data(std::nullptr_t) : base(nullptr) {
}

void vu::data::set_reference(int32_t const value) {
    impl_ptr<impl>()->_reference_setter.send_value(value);
}

int32_t vu::data::reference() const {
    return impl_ptr<impl>()->_reference.value();
}

void vu::data::set_indicator_count(uint32_t const value) {
    impl_ptr<impl>()->_indicator_count_setter.send_value(value);
}

uint32_t vu::data::indicator_count() const {
    return impl_ptr<impl>()->_indicator_count.value();
}

flow::node<int32_t> vu::data::begin_reference_flow() const {
    return impl_ptr<impl>()->_reference.begin_value_flow();
}

flow::receiver<> &vu::data::reference_increment_receiver() {
    return impl_ptr<impl>()->_ref_inc_sender.receiver();
}

flow::receiver<> &vu::data::reference_decrement_receiver() {
    return impl_ptr<impl>()->_ref_dec_sender.receiver();
}

flow::node<uint32_t> vu::data::begin_indicator_count_flow() const {
    return impl_ptr<impl>()->_indicator_count.begin_value_flow();
}

flow::receiver<> &vu::data::indicator_count_increment_receiver() {
    return impl_ptr<impl>()->_ind_inc_sender.receiver();
}

flow::receiver<> &vu::data::indicator_count_decrement_receiver() {
    return impl_ptr<impl>()->_ind_dec_sender.receiver();
}
