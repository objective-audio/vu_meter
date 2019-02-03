//
//  vu_ui.mm
//

#include "vu_ui_main.hpp"
#include <cpp_utils/yas_fast_each.h>
#include "vu_main.hpp"
#include "vu_ui_indicator_layout.hpp"
#include "yas_flow_utils.h"

using namespace yas;

namespace yas::vu {
static float constexpr padding = 4.0f;
}

void vu::ui_main::setup(ui::renderer &&renderer, main_ptr_t &main) {
    this->_weak_main = main;
    this->renderer = std::move(renderer);
    this->_indicator_resource = ui_indicator_resource(this->renderer);

    ui::texture texture{{.point_size = {1024, 1024}}};
    texture.sync_scale_from_renderer(this->renderer);

    ui_stepper_resource resource{texture};

    this->_setup_frame_guide_rect();
    this->_setup_indicators(main);
}

void vu::ui_main::_setup_frame_guide_rect() {
    auto const &safe_area_guide_rect = this->renderer.safe_area_layout_guide_rect();

    ui::insets insets{.left = vu::padding, .right = -vu::padding, .bottom = vu::padding, .top = -vu::padding};

    this->_flows.emplace_back(safe_area_guide_rect.begin_flow()
                                  .map(flow::add<ui::region>(insets))
                                  .receive(this->_frame_guide_rect.receiver())
                                  .sync());
}

void vu::ui_main::_setup_indicators(main_ptr_t &main) {
    this->_flows.emplace_back(main->indicator_count.begin_flow()
                                  .perform([this](std::size_t const &value) {
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
                                  })
                                  .to_tuple()
                                  .combine(this->_frame_guide_rect.begin_flow().to_tuple())
                                  .map([](std::tuple<std::size_t, ui::region> const &tuple) {
                                      std::size_t const &count = std::get<0>(tuple);
                                      ui::region const &region = std::get<1>(tuple);
                                      return ui_indicator_layout::regions(count, region);
                                  })
                                  .perform([this](std::vector<ui::region> const &regions) {
                                      std::size_t const count = std::min(this->indicators.size(), regions.size());
                                      auto each = make_fast_each(count);
                                      while (yas_each_next(each)) {
                                          std::size_t const &idx = yas_each_index(each);
                                          ui::region const &region = regions.at(idx);
                                          this->indicators.at(idx).frame_layout_guide_rect().set_region(region);

                                          if (idx == 0) {
                                              this->_indicator_resource.set_vu_height(region.size.height);
                                          }
                                      }
                                  })
                                  .sync());
}

void vu::ui_main::_add_indicator() {
    if (auto main = this->_weak_main.lock()) {
        std::size_t const idx = this->indicators.size();
        ui_indicator indicator;
        this->renderer.root_node().add_sub_node(indicator.node());
        indicator.setup(main, this->_indicator_resource, idx);
        this->indicators.emplace_back(std::move(indicator));
    }
}

void vu::ui_main::_remove_indicator() {
    if (this->indicators.size() == 0) {
        throw std::runtime_error("");
    }
    ui_indicator &indicator = this->indicators.at(this->indicators.size() - 1);
    indicator.node().remove_from_super_node();
    this->indicators.pop_back();
}
