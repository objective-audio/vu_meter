//
//  vu_ui_indicator_factory.hpp
//

#pragma once

#include <memory>

namespace yas::vu {
class ui_indicator;
class ui_indicator_resource;
class main;

struct ui_indicator_factory final {
    std::shared_ptr<ui_indicator> make_indicator(std::size_t const idx);

    static std::shared_ptr<ui_indicator_factory> make_shared(std::shared_ptr<ui_indicator_resource> const &);

   private:
    std::shared_ptr<ui_indicator_resource> const _resource;

    ui_indicator_factory(std::shared_ptr<ui_indicator_resource> const &);
};
}  // namespace yas::vu
