//
//  vu_ui_indicator_presenter.hpp
//

#pragma once

#include <ui/yas_ui_umbrella.h>

namespace yas::vu {
class audio_graph;
class indicator;

struct ui_indicator_presenter final {
    [[nodiscard]] ui::angle meter_angle() const;
    [[nodiscard]] std::string ch_number_text() const;

    [[nodiscard]] static std::shared_ptr<ui_indicator_presenter> make_shared(std::size_t const idx);

   private:
    std::weak_ptr<indicator> const _weak_indicator;
    std::size_t const _idx;

    ui_indicator_presenter(std::shared_ptr<indicator> const &, std::size_t const idx);
};
}  // namespace yas::vu
