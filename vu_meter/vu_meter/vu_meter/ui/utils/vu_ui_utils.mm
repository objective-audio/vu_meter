//
//  vu_ui_utils.mm
//

#include "vu_ui_utils.hpp"
#include <audio/yas_audio_umbrella.hpp>
#include "vu_ui_color.hpp"

using namespace yas;
using namespace yas::vu;

namespace yas::vu {
static std::vector<ui::uint_size> block_sizes(std::size_t const count) {
    std::vector<ui::uint_size> result;

    auto each = make_fast_each(count);
    while (yas_each_next(each)) {
        uint32_t const h_count = uint32_t(yas_each_index(each) + 1);
        uint32_t v_count = uint32_t(count / h_count);
        if ((count - h_count * v_count) > 0) {
            v_count++;
        }
        result.emplace_back(ui::uint_size{h_count, v_count});
    }
    return result;
}
}  // namespace yas::vu

std::vector<ui::region> ui_utils::indicator_regions(std::size_t const count, ui::region const region) {
    if (count == 0) {
        return std::vector<ui::region>{};
    }

    float const region_ratio = region.size.width / region.size.height;

    auto block_sizes = vu::block_sizes(count);

    std::size_t max_idx = 0;
    float max_area = 0.0f;
    ui::uint_size max_size;
    ui::size max_scaled_size;

    if (auto each = make_fast_each(count); true) {
        while (yas_each_next(each)) {
            auto const &idx = yas_each_index(each);
            auto const &size = block_sizes.at(idx);

            float const normal_width = size.width * 100.0f + (size.width - 1) * 1.0f;
            float const normal_height = size.height * 50.0f + (size.height - 1) * 1.0f;

            float const normal_ratio = normal_width / normal_height;
            ui::size scaled_size;
            if (region_ratio < normal_ratio) {
                // 横幅が広い
                float const width = region.size.width;
                float const height = width / normal_ratio;
                scaled_size = ui::size{width, height};
            } else {
                // 縦幅が広い
                float const height = region.size.height;
                float const width = height * normal_ratio;
                scaled_size = ui::size{width, height};
            }

            float const area = scaled_size.width * scaled_size.height;
            if (max_area <= area) {
                max_area = area;
                max_idx = idx;
                max_size = size;
                max_scaled_size = scaled_size;
            }
        }
    }

    auto h_positions = ui::justify(0.0, max_scaled_size.width, max_size.width * 2 - 1,
                                   [](std::size_t const &idx) { return idx % 2 ? 1.0f : 100.0f; });
    auto v_positions = ui::justify(0.0, max_scaled_size.height, max_size.height * 2 - 1,
                                   [](std::size_t const &idx) { return idx % 2 ? 1.0f : 50.0f; });

    float const origin_y = region.bottom() + (region.size.height - max_scaled_size.height) * 0.5f;
    float const origin_x = region.left() + (region.size.width - max_scaled_size.width) * 0.5f;

    std::vector<ui::region> regions;

    if (auto v_each = make_fast_each(max_size.height); true) {
        while (yas_each_next(v_each)) {
            std::size_t const &v_idx = yas_each_index(v_each);
            std::size_t const bottom_idx = (max_size.height - 1 - v_idx) * 2;
            std::size_t const top_idx = bottom_idx + 1;
            float const bottom = origin_y + v_positions.at(bottom_idx);
            float const top = origin_y + v_positions.at(top_idx);

            auto h_each = make_fast_each(max_size.width);
            while (yas_each_next(h_each)) {
                std::size_t const &h_idx = yas_each_index(h_each);
                std::size_t const left_idx = h_idx * 2;
                std::size_t const right_idx = left_idx + 1;
                float const left = origin_x + h_positions.at(left_idx);
                float const right = origin_x + h_positions.at(right_idx);

                regions.emplace_back(ui::region{.origin = {.x = left, .y = bottom},
                                                .size = {.width = right - left, .height = top - bottom}});
            }
        }
    }

    return regions;
}

ui::angle vu::ui_utils::meter_angle(float const value, float const half_degrees) {
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
