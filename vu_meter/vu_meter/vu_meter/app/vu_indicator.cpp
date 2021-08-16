//
//  vu_indicator.cpp
//

#include "vu_indicator.hpp"

#include <audio/yas_audio_umbrella.h>

#include "vu_settings.hpp"

using namespace yas;
using namespace yas::vu;

indicator::indicator(std::shared_ptr<settings_for_indicator> const &settings) : _weak_settings(settings) {
}

void indicator::set_raw_value(float const value) {
    this->_raw_value.store(value);
}

float indicator::value() const {
    if (auto const settings = this->_weak_settings.lock()) {
        float const db_value = audio::math::decibel_from_linear(this->_raw_value.load());
        return audio::math::linear_from_decibel(db_value - settings->reference());
    } else {
        return 0.0f;
    }
}

std::shared_ptr<indicator> indicator::make_shared(std::shared_ptr<settings_for_indicator> const &settings) {
    return std::shared_ptr<indicator>(new indicator{settings});
}
