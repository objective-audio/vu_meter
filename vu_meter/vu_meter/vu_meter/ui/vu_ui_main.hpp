//
//  vu_ui.hpp
//

#pragma once

#include "yas_ui.h"
#include "vu_ui_reference.hpp"

namespace yas::vu {
class main;

struct ui_main {
    ui::renderer renderer{ui::metal_system{make_objc_ptr(MTLCreateSystemDefaultDevice()).object()}};

    ui_reference reference;

    void setup(data &data);
};
}
