//
//  vu_ui.mm
//

#include "vu_ui_main.hpp"
#include "vu_main.hpp"

using namespace yas;

void vu::ui_main::setup(ui::renderer &&renderer, main_ptr_t &main) {
    this->renderer.set_value(std::move(renderer));

    weak_main_ptr_t weak_main = main;

    ui::texture texture{{.point_size = {1024, 1024}}};
    texture.observe_scale_from_renderer(this->renderer.value());

    ui::node &root_node = this->renderer.value().root_node();

    // reference

    root_node.add_sub_node(this->reference.node);

    this->reference.setup(main, texture);

    auto const &safe_area_guide_rect = this->renderer.value().safe_area_layout_guide_rect();

    this->_flows.emplace_back(ui::make_flow({.source_guide = safe_area_guide_rect.bottom(),
                                             .destination_guide = this->reference.layout_guide_rect.bottom()}));
    this->_flows.emplace_back(ui::make_flow({.source_guide = safe_area_guide_rect.bottom(),
                                             .destination_guide = this->reference.layout_guide_rect.top(),
                                             .distance = 60.0f}));
    this->_flows.emplace_back(ui::make_flow(
        {.source_guide = safe_area_guide_rect.left(), .destination_guide = this->reference.layout_guide_rect.left()}));
    this->_flows.emplace_back(ui::make_flow({.source_guide = safe_area_guide_rect.right(),
                                             .destination_guide = this->reference.layout_guide_rect.right()}));

    // indicators

    ui::layout_guide indicator_0_left_guide;
    ui::layout_guide indicator_0_right_guide;
    ui::layout_guide indicator_1_left_guide;
    ui::layout_guide indicator_1_right_guide;
    this->_flows.emplace_back(ui::make_flow({.first_source_guide = safe_area_guide_rect.left(),
                                             .second_source_guide = safe_area_guide_rect.right(),
                                             .ratios = {100.0f, 1.0f, 100.0f},
                                             .destination_guides = {indicator_0_left_guide, indicator_0_right_guide,
                                                                    indicator_1_left_guide, indicator_1_right_guide}}));

    ui::layout_guide center_y_guide;

    this->_flows.emplace_back(
        ui::make_flow({.first_source_guide = safe_area_guide_rect.top(),
                       .second_source_guide = this->reference.layout_guide_rect.top(),
                       .destination_guides = {ui::layout_guide{}, center_y_guide, ui::layout_guide{}}}));

    for (auto const &idx : {0, 1}) {
        auto &indicator = this->indicators.at(idx);
        root_node.add_sub_node(indicator.node);
        indicator.setup(main, idx);

        auto make_vertical_flow = [](ui::layout_guide &src_left, ui::layout_guide &src_right, ui::layout_guide &src_y,
                                     ui::layout_guide &dst_bottom, ui::layout_guide &dst_top) {
            auto flow = src_left.begin_flow()
                            .combine(src_right.begin_flow())
                            .combine(src_y.begin_flow())
                            .guard([](auto const &pair) {
                                return pair.first && pair.second && pair.first->first && pair.first->second;
                            })
                            .perform([dst_bottom, dst_top](auto const &pair) mutable {
                                float const src_left = *pair.first->first;
                                float const src_right = *pair.first->second;
                                float const src_y = *pair.second;
                                float const height = (src_right - src_left) * 0.5f;

                                dst_bottom.push_notify_waiting();
                                dst_top.push_notify_waiting();

                                dst_bottom.set_value(std::round(src_y - height * 0.5f));
                                dst_top.set_value(std::round(src_y + height * 0.5f));

                                dst_top.pop_notify_waiting();
                                dst_bottom.pop_notify_waiting();
                            })
                            .end();

            flow.sync();

            return flow;
        };

        if (idx == 0) {
            this->_flows.emplace_back(ui::make_flow({.source_guide = indicator_0_left_guide,
                                                     .destination_guide = indicator.frame_layout_guide_rect.left()}));
            this->_flows.emplace_back(ui::make_flow({.source_guide = indicator_0_right_guide,
                                                     .destination_guide = indicator.frame_layout_guide_rect.right()}));
            this->_flows.emplace_back(make_vertical_flow(indicator_0_left_guide, indicator_0_right_guide,
                                                         center_y_guide, indicator.frame_layout_guide_rect.bottom(),
                                                         indicator.frame_layout_guide_rect.top()));
        } else {
            this->_flows.emplace_back(ui::make_flow({.source_guide = indicator_1_left_guide,
                                                     .destination_guide = indicator.frame_layout_guide_rect.left()}));
            this->_flows.emplace_back(ui::make_flow({.source_guide = indicator_1_right_guide,
                                                     .destination_guide = indicator.frame_layout_guide_rect.right()}));
            this->_flows.emplace_back(make_vertical_flow(indicator_1_left_guide, indicator_1_right_guide,
                                                         center_y_guide, indicator.frame_layout_guide_rect.bottom(),
                                                         indicator.frame_layout_guide_rect.top()));
        }
    }

    // renderer observing

    this->_renderer_observer = this->renderer.value().subject().make_value_observer(
        ui::renderer::method::will_render, [this, weak_main, texture](auto const &) mutable {
            for (auto &indicator : this->indicators) {
                indicator.update();
            }
        });
}
