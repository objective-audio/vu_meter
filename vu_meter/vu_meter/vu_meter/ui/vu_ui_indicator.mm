//
//  vu_indicator.mm
//

#include "vu_ui_indicator.hpp"
#include "yas_audio.h"
#include "vu_main.hpp"

using namespace yas;

namespace yas::vu {
namespace constants {
    static float constexpr indicator_height_rate = 1.0f;
    static float constexpr indicator_width_rate = 2.0f;
    static float constexpr needle_x_rate = 1.0f;
    static float constexpr needle_y_rate = 0.25f;
    static float constexpr needle_height_rate = 0.5f;
    static float constexpr needle_width_rate = 0.5f / 100.0f;
    static float constexpr gridline_height_rate = 1.0f / 20.0f;
    static float constexpr gridline_width_rate = 1.0f / 100.0f;

    static auto const params = {-20, -10, -7, -5, -3, -2, -1, 0, 1, 2, 3};
}

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

    for (auto const &param : constants::params) {
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

void vu::ui_indicator::layout(float const rate) {
    float const indicator_height = constants::indicator_height_rate * rate;
    float const indicator_width = constants::indicator_width_rate * rate;
    float const needle_x = constants::needle_x_rate * rate;
    float const needle_y = constants::needle_y_rate * rate;
    float const needle_height = constants::needle_height_rate * rate;
    float const needle_width = constants::needle_width_rate * rate;
    float const gridline_height = constants::gridline_height_rate * rate;
    float const gridline_width = constants::gridline_width_rate * rate;

    this->needle.node().set_position({.x = needle_x});
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
