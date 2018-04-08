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

    ui::layout_guide center_x_left_guide;
    ui::layout_guide center_x_right_guide;
    this->_layouts.emplace_back(ui::make_layout(
        {.first_source_guide = safe_area_guide_rect.left(),
         .second_source_guide = safe_area_guide_rect.right(),
         .ratios = {100.0f, 1.0f, 100.0f},
         .destination_guides = {ui::layout_guide{}, center_x_left_guide, center_x_right_guide, ui::layout_guide{}}}));

    ui::layout_guide center_y_guide;

    this->_layouts.emplace_back(
        ui::make_layout({.first_source_guide = safe_area_guide_rect.top(),
                         .second_source_guide = this->reference.layout_guide_rect.top(),
                         .destination_guides = {ui::layout_guide{}, center_y_guide, ui::layout_guide{}}}));

    for (auto const &idx : {0, 1}) {
        auto &indicator = this->indicators.at(idx);
        root_node.add_sub_node(indicator.node);
        indicator.setup(main, idx);

#warning todo safe_areaの位置にバインドする
        if (idx == 0) {
            this->_layouts.emplace_back(ui::make_layout({.source_guide = safe_area_guide_rect.left(),
                                                         .destination_guide = indicator.layout_guide_rect.left()}));
            this->_layouts.emplace_back(ui::make_layout(
                {.source_guide = center_x_left_guide, .destination_guide = indicator.layout_guide_rect.right()}));
        } else if (idx == 1) {
            this->_layouts.emplace_back(ui::make_layout(
                {.source_guide = center_x_right_guide, .destination_guide = indicator.layout_guide_rect.left()}));
            this->_layouts.emplace_back(ui::make_layout({.source_guide = safe_area_guide_rect.right(),
                                                         .destination_guide = indicator.layout_guide_rect.right()}));
        }

        this->_layouts.emplace_back(
            ui::layout{{.source_guides = {safe_area_guide_rect.left(), safe_area_guide_rect.right(), center_y_guide},
                        .destination_guides = {indicator.layout_guide_rect.bottom()},
                        .handler = [](std::vector<ui::layout_guide> const &source_guides,
                                      std::vector<ui::layout_guide> &destination_guides) {
                            ui::layout_guide const &src_left = source_guides.at(0);
                            ui::layout_guide const &src_right = source_guides.at(1);
                            ui::layout_guide const &src_y_guide = source_guides.at(2);
                            ui::layout_guide &dst_guide = destination_guides.at(0);

                            float const height = (src_right.value() - src_left.value()) * 0.5f;

                            dst_guide.set_value(std::round(src_y_guide.value() - height * 0.5f));
                        }}});
    }

    // renderer observing

    this->_renderer_observer =
        this->renderer.subject().make_wild_card_observer([this, weak_main, texture](auto const &context) mutable {
            ui::renderer::method const &method = context.key;
            switch (method) {
                case ui::renderer::method::will_render: {
                    for (auto &indicator : this->indicators) {
                        indicator.update();
                    }
                } break;
                case ui::renderer::method::view_size_changed:
                case ui::renderer::method::safe_area_insets_changed: {
                    ui::renderer const &renderer = context.value;

                    ui::region const safe_area_region = renderer.safe_area_layout_guide_rect().region();
                    if (safe_area_region.horizontal_range().length > 0.0 &&
                        safe_area_region.vertical_range().length > 0.0) {
                        float const height = safe_area_region.horizontal_range().length * 0.25f;
                        for (auto &indicator : this->indicators) {
                            indicator.layout(height, texture);
                        }
                    }
#warning todo
                } break;
                default:
                    break;
            }
        });
}
