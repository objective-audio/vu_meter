//
//  audio_format.hpp
//

#pragma once

#include <cstddef>

namespace yas::vu {
struct audio_format {
    std::size_t channel_count{0};
    double sample_rate{0.0};

    bool operator==(audio_format const &rhs) const;
    bool operator!=(audio_format const &rhs) const;
};
}  // namespace yas::vu
