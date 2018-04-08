//
//  vu_indicator.mm
//

#include "vu_ui_indicator.hpp"
#include "yas_audio.h"
#include "vu_main.hpp"
#include "yas_fast_each.h"
#include "vu_ui_utils.hpp"
#include "vu_ui_color.hpp"

using namespace yas;

namespace yas::vu {
namespace constants {
    static float constexpr needle_root_x_rate = 1.0f;
    static float constexpr needle_root_y_rate = -0.2f;
    static float constexpr needle_height_rate = 1.0f;
    static float constexpr needle_width_rate = 0.01f;
    static float constexpr gridline_y_rate = 1.0f;
    static float constexpr gridline_top_y_rate = needle_height_rate * 0.9f;
    static float constexpr gridline_height_rate = 0.1f;
    static float constexpr gridline_width_rate = gridline_height_rate * 0.15f;
    static float constexpr number_y_rate = 1.15f;
    static float constexpr number_font_size_rate = 1.0f / 7.0f;

    static std::array<int32_t, 11> params{-20, -10, -7, -5, -3, -2, -1, 0, 1, 2, 3};
}
}

void vu::ui_indicator::setup(main_ptr_t &main, std::size_t const idx) {
    weak_main_ptr_t weak_main = main;
    this->_weak_main = weak_main;

    this->idx = idx;

    // base_plane

    this->base_plane.node().set_color(vu::indicator_base_color());
    this->node.add_sub_node(this->base_plane.node());

    // needle_root_node
    this->node.add_sub_node(this->needle_root_node);

    // needle
    this->needle.node().set_color(vu::indicator_needle_color());
    this->needle_root_node.add_sub_node(this->needle.node());

    // numbers
    for (auto const &param : constants::params) {
        auto &handle = this->gridline_handles.emplace_back();
        auto &plane = this->gridlines.emplace_back(1);

        ui::strings::args args{
            .text = std::to_string(param), .max_word_count = 3, .alignment = ui::layout_alignment::mid};
        auto &number = this->numbers.emplace_back(std::move(args));

        this->needle_root_node.add_sub_node(handle);
        handle.add_sub_node(plane.node());
        handle.add_sub_node(number.rect_plane().node());

        ui::angle const angle =
            ui_utils::meter_angle(audio::math::linear_from_decibel(static_cast<float>(param)), 0.0f);
        handle.set_angle(angle);
        number.rect_plane().node().set_angle(-angle);

        plane.node().set_color(vu::indicator_gridline_color());
        number.rect_plane().node().set_color(vu::indicator_number_color());
    }

    this->_data_observer = main->data.subject.make_observer(vu::data::method::reference_changed,
                                                            [this](auto const &context) { this->update(); });

    // layout_guide

    this->layout_guide_rect.set_value_changed_handler([this](ui::layout_guide_rect::change_context const &context) {
        ui::region const &old_region = context.old_value;
        ui::region const &region = context.new_value;

        this->layout();

        // 高さが変わったら文字の大きさも変わるのでfont_atlasを作り直す
        if (old_region.size.height != region.size.height) {
            this->font_atlas = nullptr;
            for (auto &number : this->numbers) {
                number.set_font_atlas(nullptr);
            }
        }
    });

    // node

    this->_node_observer =
        this->node.subject().make_observer(ui::node::method::renderer_changed, [this](auto const &context) {
            if (!this->font_atlas) {
                return;
            }

            if (ui::texture texture = this->font_atlas.texture()) {
                ui::node const &node = context.value;
                if (ui::renderer renderer = node.renderer()) {
                    texture.observe_scale_from_renderer(renderer);
                }
            }
        });

    this->update();
}

void vu::ui_indicator::layout() {
    ui::region const region = this->layout_guide_rect.region();
    ui::size const size = region.size;
    float const width = size.width;
    float const height = size.height;
    if (width <= 0.0f || height <= 0.0f) {
        return;
    }

    float const needle_root_x = constants::needle_root_x_rate * height;
    float const needle_root_y = constants::needle_root_y_rate * height;
    float const needle_height = constants::needle_height_rate * height;
    float const needle_width = constants::needle_width_rate * height;
    float const gridline_y = constants::gridline_y_rate * height;
    float const gridline_height = constants::gridline_height_rate * height;
    float const gridline_width = constants::gridline_width_rate * height;

    // node
    this->node.set_position({.x = region.left(), .y = region.bottom()});

    // base_plane
    this->base_plane.data().set_rect_position({.size = {width, height}}, 0);

    // needle
    this->needle_root_node.set_position({.x = needle_root_x, .y = needle_root_y});
    this->needle.data().set_rect_position(
        {.origin = {.x = -needle_width * 0.5f}, .size = {.width = needle_width, .height = needle_height}}, 0);

    // gridline
    for (auto &gridline : this->gridlines) {
        gridline.node().set_position({.y = gridline_y});
        gridline.data().set_rect_position({.origin = {.x = -gridline_width * 0.5f, .y = -gridline_height * 0.5f},
                                           .size = {.width = gridline_width, .height = gridline_height}},
                                          0);
    }

    float const number_y = constants::number_y_rate * height;
    for (auto &number : this->numbers) {
        number.rect_plane().node().set_position({.y = number_y});
    }
}

void vu::ui_indicator::update() {
    if (!this->font_atlas) {
        if (float const height = this->layout_guide_rect.region().size.height; height > 0.0f) {
            ui::texture texture{{.point_size = {1024, 1024}}};
            if (auto renderer = this->node.renderer()) {
                texture.observe_scale_from_renderer(renderer);
            }

            float const font_size = constants::number_font_size_rate * height;

            this->font_atlas = ui::font_atlas{{.font_name = "AmericanTypewriter-Bold",
                                               .font_size = font_size,
                                               .words = "012357-",
                                               .texture = texture}};
            for (auto &number : this->numbers) {
                number.set_font_atlas(this->font_atlas);
            }
        }
    }

    if (auto main = this->_weak_main.lock()) {
        ui::angle const angle = ui_utils::meter_angle(main->values.at(this->idx).load(), main->data.reference());
        this->needle.node().set_angle(angle);
    }
}
