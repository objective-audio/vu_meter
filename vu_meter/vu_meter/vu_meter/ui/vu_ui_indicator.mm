//
//  vu_indicator.mm
//

#include "vu_ui_indicator.hpp"
#include "yas_audio.h"
#include "vu_main.hpp"

using namespace yas;

namespace yas::vu {
static float constexpr indicator_height_base = 1.0f;
static float constexpr indicator_width_base = 2.0f;
static float constexpr needle_height_base = 1.0f;
static float constexpr needle_width_base = 1.0f / 100.0f;
static float constexpr gridline_height_base = 1.0f / 20.0f;
static float constexpr gridline_width_base = 1.0f / 100.0f;

ui::angle meter_angle(float const in_value, float const reference) {
    float const db_value = audio::math::decibel_from_linear(in_value);
    float const value = audio::math::linear_from_decibel(db_value - reference);

    float const min = audio::math::linear_from_decibel(-20.0);
    float const max = audio::math::linear_from_decibel(3.0);
    float const min_to_one = 1.0f - min;
    float const min_to_max = max - min;
    float const value1 = (value - min) / min_to_one;
    float const meterValue = value1 / min_to_max;

    return {.degrees = 45.0f + meterValue * -90.0f};
}
}

void vu::ui_indicator::setup(main_ptr_t &main, ui::texture &texture, std::size_t const idx) {
    weak_main_ptr_t weak_main = main;
    this->_weak_main = weak_main;

    this->idx = idx;

    this->needle.node().set_color(ui::blue_color());
    this->node.add_sub_node(this->needle.node());

    auto const params = {-20, -10, -7, -5, -3, -2, -1, 0, 1, 2, 3};

    for (auto const &param : params) {
        auto &handle = this->gridlineHandles.emplace_back();
        auto &plane = this->gridlines.emplace_back(ui::make_rect_plane(1));

        ui::strings::args args{.text = std::to_string(param),
                               .max_word_count = 3,
                               .font_atlas = this->font_atlas,
                               .alignment = ui::layout_alignment::mid};
        auto &number = this->numbers.emplace_back(std::move(args));

        this->node.add_sub_node(handle);
        handle.add_sub_node(plane.node());
        handle.add_sub_node(number.rect_plane().node());
    }

    this->_data_observer = main->data.subject.make_observer(vu::data::method::reference_changed,
                                                            [this](auto const &context) { this->update(); });
    this->update();
}

void vu::ui_indicator::layout(float const height) {
    float const indicator_height = indicator_height_base * height;
    float const indicator_width = indicator_width_base * height;
    float const needle_height = needle_height_base * height;
    float const needle_width = needle_width_base * height;
    float const gridline_height = gridline_height_base * height;
    float const gridline_width = gridline_width_base * height;

    this->needle.data().set_rect_position(
        {.origin = {.x = -needle_width * 0.5f}, .size = {.width = needle_width, .height = needle_height}}, 0);
#warning todo viewの大きさに合わせて位置を調整する
}

void vu::ui_indicator::update() {
    if (auto main = this->_weak_main.lock()) {
        ui::angle const angle = meter_angle(main->values.at(this->idx).load(), main->data.reference());
        this->needle.node().set_angle(angle);
    }
}
