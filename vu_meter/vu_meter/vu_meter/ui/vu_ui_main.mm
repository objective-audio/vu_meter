//
//  vu_ui.mm
//

#include "vu_ui_main.hpp"
#include <cpp_utils/yas_fast_each.h>
#include "vu_main.hpp"
#include "vu_ui_color.hpp"
#include "vu_ui_indicator_layout.hpp"

using namespace yas;
using namespace yas::vu;

namespace yas::vu {
static float constexpr padding = 4.0f;
}

ui_main::ui_main(std::shared_ptr<ui::standard> const &standard, main_ptr_t const &main)
    : _standard(standard),
      _weak_main(main),
      _indicator_resource(ui_indicator_resource::make_shared(standard->view_look())) {
    standard->view_look()->background()->set_color(vu::base_color());

    this->_setup_frame_guide_rect();
    this->_setup_indicators(main);
}

void vu::ui_main::_setup_frame_guide_rect() {
    auto const &safe_area_guide = this->_standard->view_look()->safe_area_layout_guide();

    safe_area_guide
        ->observe([this](ui::region const &region) {
            ui::region_insets const insets{
                .left = vu::padding, .right = -vu::padding, .bottom = vu::padding, .top = -vu::padding};
            this->_frame_guide->set_region(region + insets);
        })
        .sync()
        ->add_to(this->_pool);
}

void vu::ui_main::_setup_indicators(main_ptr_t const &main) {
    struct cache {
        std::optional<std::size_t> count{std::nullopt};
        std::optional<ui::region> region{std::nullopt};
    };

    std::function<void(std::optional<std::size_t> const &, std::optional<ui::region> const &)> lambda =
        [this, shared_cache = std::make_shared<cache>()](std::optional<std::size_t> const &count,
                                                         std::optional<ui::region> const &region) {
            if (count.has_value()) {
                shared_cache->count = count;
            } else if (region.has_value()) {
                shared_cache->region = region;
            }

            if (!shared_cache->count.has_value() || !shared_cache->region.has_value()) {
                return;
            }

            auto const regions =
                ui_indicator_layout::regions(shared_cache->count.value(), shared_cache->region.value());

            std::size_t const _count = std::min(this->indicators.size(), regions.size());
            auto each = make_fast_each(_count);
            while (yas_each_next(each)) {
                std::size_t const &idx = yas_each_index(each);
                ui::region const &region = regions.at(idx);
                this->indicators.at(idx)->frame_layout_guide_rect()->set_region(region);

                if (idx == 0) {
                    this->_indicator_resource->set_vu_height(region.size.height);
                }
            }
        };

    main->indicator_count
        ->observe([this, lambda](std::size_t const &value) {
            if (value < this->indicators.size()) {
                auto each = make_fast_each(this->indicators.size() - value);
                while (yas_each_next(each)) {
                    this->_remove_indicator();
                }
            } else if (this->indicators.size() < value) {
                auto each = make_fast_each(value - this->indicators.size());
                while (yas_each_next(each)) {
                    this->_add_indicator();
                }
            }

            lambda(value, std::nullopt);
        })
        .sync()
        ->add_to(this->_pool);

    this->_frame_guide
        ->observe([lambda = std::move(lambda)](ui::region const &region) { lambda(std::nullopt, region); })
        .sync()
        ->add_to(this->_pool);
}

void vu::ui_main::_add_indicator() {
    if (auto main = this->_weak_main.lock()) {
        std::size_t const idx = this->indicators.size();
        ui_indicator_ptr indicator = ui_indicator::make_shared(this->_standard);
        this->_standard->root_node()->add_sub_node(indicator->node());
        indicator->setup(main, this->_indicator_resource, idx);
        this->indicators.emplace_back(std::move(indicator));
    }
}

void vu::ui_main::_remove_indicator() {
    if (this->indicators.size() == 0) {
        throw std::runtime_error("");
    }
    ui_indicator_ptr const &indicator = this->indicators.at(this->indicators.size() - 1);
    indicator->node()->remove_from_super_node();
    this->indicators.pop_back();
}

vu::ui_main_ptr_t vu::ui_main::make_shared(std::shared_ptr<ui::standard> const &standard, main_ptr_t const &main) {
    return std::shared_ptr<ui_main>(new ui_main{standard, main});
}
