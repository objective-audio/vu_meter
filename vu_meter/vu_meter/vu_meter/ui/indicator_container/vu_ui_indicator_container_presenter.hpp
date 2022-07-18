//
//  vu_ui_indicator_container_presenter.hpp
//

#pragma once

#include <observing/yas_observing_umbrella.h>

#include <memory>

namespace yas::vu {
class indicator_lifecycle;

struct vu_ui_indicator_container_presenter final {
    [[nodiscard]] std::size_t indicator_count() const;
    [[nodiscard]] observing::syncable observe_indicator_count(std::function<void(std::size_t const &)> &&);

    [[nodiscard]] static std::shared_ptr<vu_ui_indicator_container_presenter> make_shared();

   private:
    observing::value::holder_ptr<std::size_t> const _indicator_count;
    observing::canceller_pool _pool;

    vu_ui_indicator_container_presenter(std::shared_ptr<indicator_lifecycle> const &);
};
}  // namespace yas::vu
