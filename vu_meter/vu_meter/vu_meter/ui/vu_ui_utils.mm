//
//  vu_ui_utils.mm
//

#include "vu_ui_utils.hpp"
#include "vu_ui_color.hpp"
#include "yas_audio.h"

using namespace yas;

ui::angle vu::ui_utils::meter_angle(float const in_value, float const reference, float const half_degrees) {
    float const db_value = audio::math::decibel_from_linear(in_value);
    float const value = audio::math::linear_from_decibel(db_value - reference);

    static float const min = audio::math::linear_from_decibel(-20.0);
    static float const max = audio::math::linear_from_decibel(3.0);
    static float const min_to_max = max - min;

    static float const max_degrees = -(half_degrees + (0.0f - min) / min_to_max * -half_degrees * 2.0f);

    float const degrees = half_degrees + (value - min) / min_to_max * -half_degrees * 2.0f;

    return {.degrees = std::max(degrees, max_degrees)};
}

float vu::ui_utils::gridline_y(ui::angle const angle, ui::angle const half_angle, float const radius,
                               float const rate) {
    float const side_y = std::cos(half_angle.radians()) * radius;
    float const top_y = std::cos(angle.radians()) * radius;
    return radius - (top_y - side_y) * rate;
}

std::function<void(CGContextRef const)> vu::ui_utils::draw_button_handler(ui::uint_size const button_size,
                                                                          bool const is_tracking, bool const is_plus) {
    return [button_size, is_tracking, is_plus](CGContextRef const ctx) {
        auto base_color = vu::setting_button_base_color(is_tracking);
        CGContextSetFillColorWithColor(
            ctx, [UIColor colorWithRed:base_color.red green:base_color.green blue:base_color.blue alpha:1.0].CGColor);
        CGContextFillRect(ctx, CGRectMake(0.0, 0.0, button_size.width, button_size.height));

        auto text_color = vu::setting_text_color();
        CGContextSetFillColorWithColor(
            ctx, [UIColor colorWithRed:text_color.red green:text_color.green blue:text_color.blue alpha:1.0].CGColor);
        CGFloat const width = button_size.width * 0.05;
        CGFloat const length = button_size.width * 0.5;
        CGContextFillRect(
            ctx, CGRectMake((button_size.width - length) * 0.5, (button_size.height - width) * 0.5, length, width));

        if (is_plus) {
            CGContextFillRect(
                ctx, CGRectMake((button_size.width - width) * 0.5, (button_size.height - length) * 0.5, width, length));
        }
    };
}
