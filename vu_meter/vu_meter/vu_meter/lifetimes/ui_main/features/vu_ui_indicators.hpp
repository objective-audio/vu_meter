//
//  vu_ui_indicators.hpp
//

#pragma once

#include <memory>
#include <observing/umbrella.hpp>

namespace yas::vu {
class indicator_lifecycle;
class ui_indicator_lifecycle;

struct ui_indicators final {
    [[nodiscard]] static std::shared_ptr<ui_indicators> make_shared(ui_indicator_lifecycle *);
    ui_indicators(indicator_lifecycle *, ui_indicator_lifecycle *);

    void setup();

   private:
    indicator_lifecycle *_source_lifecycle;
    ui_indicator_lifecycle *_ui_lifecycle;

    observing::canceller_pool _pool;
};
}  // namespace yas::vu
