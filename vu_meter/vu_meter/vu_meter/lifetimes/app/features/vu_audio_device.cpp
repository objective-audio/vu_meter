//
//  vu_audio_device.cpp
//

#include "vu_audio_device.hpp"

#include <audio/yas_audio_umbrella.hpp>
#include <iostream>

using namespace yas;
using namespace yas::vu;

std::shared_ptr<audio_device> audio_device::make_shared() {
    auto const &session = audio::ios_session::shared();

    session->set_category(audio::ios_session::category::record);

    auto const result = session->activate();
    if (result) {
        return std::make_shared<audio_device>(audio::ios_device::make_shared(session));
    } else {
        std::cout << "session activate result : " << result.error() << std::endl;
        return std::make_shared<audio_device>(std::nullopt);
    }
}

audio_device::audio_device(std::optional<std::shared_ptr<audio::ios_device>> const &ios_device)
    : _ios_device(ios_device), _format(observing::value::holder<audio_format>::make_shared({})) {
    this->_format->set_value(this->_make_format());

    if (this->_ios_device.has_value()) {
        this->_ios_device.value()
            ->observe_io_device([this](auto const &) { this->_format->set_value(this->_make_format()); })
            .end()
            ->add_to(this->_pool);
    }
}

std::optional<std::shared_ptr<audio::ios_device>> const &audio_device::ios_device() const {
    return this->_ios_device;
}

audio_format const &audio_device::format() const {
    return this->_format->value();
}

observing::syncable audio_device::observe_format(std::function<void(audio_format const &)> &&handler) {
    return this->_format->observe(std::move(handler));
}

void audio_device::did_become_active() {
    audio::ios_session::shared()->did_become_active();
}

audio_format audio_device::_make_format() const {
    if (auto const &device = this->_ios_device) {
        if (auto const &format = device.value()->input_format()) {
            return {device.value()->input_channel_count(), format.value().sample_rate()};
        }
    }
    return {};
}
