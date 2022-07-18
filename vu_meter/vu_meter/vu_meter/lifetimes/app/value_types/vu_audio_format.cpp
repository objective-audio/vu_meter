//
//  vu_audio_format.cpp
//

#include "vu_audio_format.hpp"

using namespace yas;
using namespace yas::vu;

bool audio_format::operator==(audio_format const &rhs) const {
    return this->channel_count == rhs.channel_count && this->sample_rate == rhs.sample_rate;
}

bool audio_format::operator!=(audio_format const &rhs) const {
    return !(*this == rhs);
}
