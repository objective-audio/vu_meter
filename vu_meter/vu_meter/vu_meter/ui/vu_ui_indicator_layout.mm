//
//  vu_ui_indicator_layout.cpp
//

#include "vu_ui_indicator_layout.hpp"
#include <vector>
#include "yas_fast_each.h"
#include "yas_ui_flow_utils.h"

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

ui_indicator_layout::ui_indicator_layout(std::size_t const count, ui::region const region)
    : _count(count), _region(region) {
    float const region_ratio = region.size.width / region.size.height;

    auto block_sizes = vu::block_sizes(count);

    std::size_t max_idx = 0;
    float max_area = 0.0f;

    auto each = make_fast_each(count);
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
        if (max_area < area) {
            max_area = area;
            max_idx = idx;
        }
    }
}
