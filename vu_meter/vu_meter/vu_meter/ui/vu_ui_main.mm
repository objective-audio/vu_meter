//
//  vu_ui.mm
//

#include "vu_ui_main.hpp"
#include "vu_main.hpp"

using namespace yas;

void vu::ui_main::setup(ui::renderer &&renderer, main_ptr_t &main) {
    this->renderer = std::move(renderer);

    weak_main_ptr_t weak_main = main;

    ui::texture texture{{.point_size = {1024, 1024}}};
    texture.observe_scale_from_renderer(this->renderer);

    ui::node &root_node = this->renderer.root_node();

    // reference

    root_node.add_sub_node(this->reference.node);

    this->reference.setup(main, texture);

    auto const &safe_area_guide_rect = this->renderer.safe_area_layout_guide_rect();

    this->_layouts.emplace_back(ui::make_layout({.source_guide = safe_area_guide_rect.bottom(),
                                                 .destination_guide = this->reference.layout_guide_rect.bottom()}));
    this->_layouts.emplace_back(ui::make_layout({.source_guide = safe_area_guide_rect.bottom(),
                                                 .destination_guide = this->reference.layout_guide_rect.top(),
                                                 .distance = 60.0f}));
    this->_layouts.emplace_back(ui::make_layout(
        {.source_guide = safe_area_guide_rect.left(), .destination_guide = this->reference.layout_guide_rect.left()}));
    this->_layouts.emplace_back(ui::make_layout({.source_guide = safe_area_guide_rect.right(),
                                                 .destination_guide = this->reference.layout_guide_rect.right()}));

    // indicators

    ui::layout_guide indicator_0_left_guide;
    ui::layout_guide indicator_0_right_guide;
    ui::layout_guide indicator_1_left_guide;
    ui::layout_guide indicator_1_right_guide;
    this->_layouts.emplace_back(
        ui::make_layout({.first_source_guide = safe_area_guide_rect.left(),
                         .second_source_guide = safe_area_guide_rect.right(),
                         .ratios = {100.0f, 1.0f, 100.0f},
                         .destination_guides = {indicator_0_left_guide, indicator_0_right_guide, indicator_1_left_guide,
                                                indicator_1_right_guide}}));

    ui::layout_guide center_y_guide;

    this->_layouts.emplace_back(
        ui::make_layout({.first_source_guide = safe_area_guide_rect.top(),
                         .second_source_guide = this->reference.layout_guide_rect.top(),
                         .destination_guides = {ui::layout_guide{}, center_y_guide, ui::layout_guide{}}}));

    for (auto const &idx : {0, 1}) {
        auto &indicator = this->indicators.at(idx);
        root_node.add_sub_node(indicator.node);
        indicator.setup(main, idx);

        if (idx == 0) {
            this->_layouts.emplace_back(
                ui::make_layout({.source_guide = indicator_0_left_guide,
                                 .destination_guide = indicator.frame_layout_guide_rect.left()}));
            this->_layouts.emplace_back(
                ui::make_layout({.source_guide = indicator_0_right_guide,
                                 .destination_guide = indicator.frame_layout_guide_rect.right()}));
        } else if (idx == 1) {
            this->_layouts.emplace_back(
                ui::make_layout({.source_guide = indicator_1_left_guide,
                                 .destination_guide = indicator.frame_layout_guide_rect.left()}));
            this->_layouts.emplace_back(
                ui::make_layout({.source_guide = indicator_1_right_guide,
                                 .destination_guide = indicator.frame_layout_guide_rect.right()}));
        }

        auto layout_handler = [](std::vector<ui::layout_guide> const &source_guides,
                                 std::vector<ui::layout_guide> &destination_guides) {
            ui::layout_guide const &src_left = source_guides.at(0);
            ui::layout_guide const &src_right = source_guides.at(1);
            ui::layout_guide const &src_y = source_guides.at(2);
            ui::layout_guide &dst_bottom = destination_guides.at(0);
            ui::layout_guide &dst_top = destination_guides.at(1);

            float const height = (src_right.value() - src_left.value()) * 0.5f;

            dst_bottom.push_notify_caller();
            dst_top.push_notify_caller();

            dst_bottom.set_value(std::round(src_y.value() - height * 0.5f));
            dst_top.set_value(std::round(src_y.value() + height * 0.5f));

            dst_top.pop_notify_caller();
            dst_bottom.pop_notify_caller();
        };

        this->_layouts.emplace_back(
            ui::layout{{.source_guides = {indicator_0_left_guide, indicator_0_right_guide, center_y_guide},
                        .destination_guides = {indicator.frame_layout_guide_rect.bottom(),
                                               indicator.frame_layout_guide_rect.top()},
                        .handler = layout_handler}});
        this->_layouts.emplace_back(
            ui::layout{{.source_guides = {indicator_1_left_guide, indicator_1_right_guide, center_y_guide},
                        .destination_guides = {indicator.frame_layout_guide_rect.bottom(),
                                               indicator.frame_layout_guide_rect.top()},
                        .handler = layout_handler}});
    }

    // renderer observing

    this->_renderer_observer = this->renderer.subject().make_value_observer(
        ui::renderer::method::will_render, [this, weak_main, texture](auto const &) mutable {
            for (auto &indicator : this->indicators) {
                indicator.update();
            }
        });
}
