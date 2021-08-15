//
//  vu_indicator.hpp
//

#pragma once

#include <ui/yas_ui_umbrella.h>

#include "vu_ui_indicator_container_dependency.h"
#include "vu_ui_indicator_dependency.h"
#include "vu_ui_indicator_presenter.hpp"
#include "vu_ui_indicator_resource.hpp"

namespace yas::vu {
struct ui_indicator final : ui_indicator_for_container {
    std::shared_ptr<ui::node> const &node() override;

    void set_region(ui::region const) override;

    static std::shared_ptr<ui_indicator> make_shared(std::shared_ptr<ui_indicator_resource_for_indicator> const &,
                                                     std::size_t const);

   private:
    class impl;

    std::unique_ptr<impl> _impl;

    ui_indicator(std::shared_ptr<ui::standard> const &, std::shared_ptr<ui_indicator_resource_for_indicator> const &,
                 std::shared_ptr<ui_indicator_presenter> const &);
};
}  // namespace yas::vu
