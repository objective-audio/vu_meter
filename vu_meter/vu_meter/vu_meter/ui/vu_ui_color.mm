//
//  vu_ui_color.mm
//

#include "vu_ui_color.hpp"

using namespace yas;

MTLClearColor const &vu::base_color() {
    static MTLClearColor _color{.red = 0.1, .green = 0.1, .blue = 0.1, .alpha = 1.0};
    return _color;
}
