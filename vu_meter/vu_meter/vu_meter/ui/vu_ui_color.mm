//
//  vu_ui_color.mm
//

#include "vu_ui_color.hpp"

using namespace yas;

MTLClearColor const &vu::base_color() {
    static MTLClearColor _color{.red = 1.0, .green = 0.0, .blue = 0.0, .alpha = 1.0};
    return _color;
}
