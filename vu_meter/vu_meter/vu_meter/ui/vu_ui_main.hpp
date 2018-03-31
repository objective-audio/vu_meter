//
//  vu_ui.hpp
//

#pragma once

#include "yas_ui.h"

namespace yas::vu {
struct ui_main {
    ui::renderer renderer{ui::metal_system{make_objc_ptr(MTLCreateSystemDefaultDevice()).object()}};

    void setup();
};
}
