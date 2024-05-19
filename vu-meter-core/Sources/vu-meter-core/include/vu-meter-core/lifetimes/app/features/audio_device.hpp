//
//  audio_device.hpp
//

#pragma once

#include <memory>
#include <observing/umbrella.hpp>
#include <optional>
#include <vu-meter-core/lifetimes/app/value_types/audio_format.hpp>

namespace yas::audio {
class ios_device;
}

namespace yas::vu {
struct audio_device final {
    [[nodiscard]] static std::shared_ptr<audio_device> make_shared();
    audio_device(std::optional<std::shared_ptr<audio::ios_device>> const &);

    std::optional<std::shared_ptr<audio::ios_device>> const &ios_device() const;

    [[nodiscard]] audio_format const &format() const;

    [[nodiscard]] observing::syncable observe_format(std::function<void(audio_format const &)> &&);

    void did_become_active();

   private:
    std::optional<std::shared_ptr<audio::ios_device>> const _ios_device;
    observing::value::holder_ptr<audio_format> const _format;
    observing::canceller_pool _pool;

    audio_format _make_format() const;
};
}  // namespace yas::vu
