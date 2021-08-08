//
//  vu_ui_indicator_presenter.hpp
//

#pragma once

#include <ui/yas_ui_umbrella.h>

namespace yas::vu {
class main;

struct ui_indicator_presenter final {
    ui::angle meter_angle() const;
    std::string ch_number_text() const;

    static std::shared_ptr<ui_indicator_presenter> make_shared(std::shared_ptr<main> const &, std::size_t const idx);

   private:
    std::weak_ptr<main> const _weak_main;
    std::size_t const _idx;

    ui_indicator_presenter(std::shared_ptr<main> const &, std::size_t const idx);
};
}  // namespace yas::vu
