//
//  vu_indicator.cpp
//

#include "vu_indicator.hpp"

#include <audio/yas_audio_umbrella.hpp>

#include "vu_indicator_value.hpp"
#include "vu_settings.hpp"

using namespace yas;
using namespace yas::vu;

std::shared_ptr<indicator> indicator::make_shared(std::shared_ptr<indicator_value> const &value,
                                                  std::shared_ptr<settings_for_indicator> const &settings) {
    return std::shared_ptr<indicator>(new indicator{value, settings});
}

indicator::indicator(std::shared_ptr<indicator_value> const &value,
                     std::shared_ptr<settings_for_indicator> const &settings)
    : _weak_settings(settings), _raw_value(value) {
}

std::shared_ptr<indicator_value> const &indicator::raw_value() const {
    return this->_raw_value;
}

float indicator::value() const {
    if (auto const settings = this->_weak_settings.lock()) {
        float const db_value = audio::math::decibel_from_linear(this->_raw_value->load());
        return audio::math::linear_from_decibel(db_value - settings->reference());
    } else {
        return 0.0f;
    }
}
