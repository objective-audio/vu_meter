//
//  vu_ui_indicator_layout.cpp
//

#include "vu_ui_indicator_layout.hpp"
#include <vector>
#include "yas_fast_each.h"

using namespace yas;
using namespace yas::vu;

namespace yas::vu {
static std::vector<ui::uint_size> sizes(std::size_t const count) {
    std::vector<ui::uint_size> result;

    auto each = make_fast_each(count);
    while (yas_each_next(each)) {
        uint32_t const h_count = uint32_t(yas_each_index(each) + 1);
        uint32_t v_count = uint32_t(count / h_count);
        if ((count - h_count * v_count) > 0) {
            v_count++;
        }
        result.emplace_back(ui::uint_size{.width = h_count, .height = v_count});
    }
    return result;
}
}  // namespace yas::vu

ui_indicator_layout::ui_indicator_layout(std::size_t const count, ui::region const region)
    : _count(count), _region(region) {
    auto sizes = vu::sizes(count);
}
