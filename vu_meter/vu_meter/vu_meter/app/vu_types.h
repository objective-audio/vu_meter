//
//  vu_types.h
//

#pragma once

#include <memory>

namespace yas::vu {
class main;
class ui_main;

using main_ptr_t = std::shared_ptr<main>;
using weak_main_ptr_t = std::weak_ptr<main>;
using ui_main_ptr_t = std::shared_ptr<ui_main>;

uint32_t constexpr indicator_count_max = 8;
uint32_t constexpr indicator_count_min = 1;
}  // namespace yas::vu
