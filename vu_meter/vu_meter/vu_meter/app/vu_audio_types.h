//
//  vu_audio_types.h
//

#pragma once

namespace yas::vu {
struct audio_format {
    std::size_t channel_count{0};
    double sample_rate{0.0};

    bool operator==(audio_format const &rhs) {
        return this->channel_count == rhs.channel_count && this->sample_rate == rhs.sample_rate;
    }

    bool operator!=(audio_format const &rhs) {
        return !(*this == rhs);
    }
};
}  // namespace yas::vu
