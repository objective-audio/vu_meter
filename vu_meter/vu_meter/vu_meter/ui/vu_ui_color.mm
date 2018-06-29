//
//  vu_ui_color.mm
//

#include "vu_ui_color.hpp"

using namespace yas;

MTLClearColor const &vu::base_color() {
    static MTLClearColor _color{.red = 0.1, .green = 0.1, .blue = 0.1, .alpha = 1.0};
    return _color;
}

ui::color const &vu::indicator_base_color() {
    static ui::color _color{.red = 0.82f, .green = 0.8f, .blue = 0.75f};
    return _color;
}

ui::color const &vu::indicator_needle_color() {
    static ui::color _color{.red = 0.1f, .green = 0.1f, .blue = 0.1f};
    return _color;
}

ui::color const &vu::indicator_gridline_color() {
    static ui::color _color{.red = 0.33f, .green = 0.33f, .blue = 0.33f};
    return _color;
}

ui::color const &vu::indicator_number_color() {
    static ui::color _color{.red = 0.33f, .green = 0.33f, .blue = 0.33f};
    return _color;
}

ui::color const &vu::indicator_ch_color() {
    static ui::color _color{.red = 0.70f, .green = 0.70f, .blue = 0.70f};
    return _color;
}

ui::color const &vu::indicator_over_gridline_color() {
    static ui::color _color{.red = 0.9f, .green = 0.05f, .blue = 0.0f};
    return _color;
}

ui::color const &vu::indicator_over_number_color() {
    static ui::color _color{.red = 0.9f, .green = 0.05f, .blue = 0.0f};
    return _color;
}

ui::color const &vu::setting_button_base_color(bool const is_tracking) {
    static ui::color _on_color{.red = 0.66f, .green = 0.66f, .blue = 0.66f};
    static ui::color _off_color{.red = 0.33f, .green = 0.33f, .blue = 0.33f};
    return is_tracking ? _on_color : _off_color;
}

ui::color const &vu::setting_text_color() {
    static ui::color _color{.red = 0.82f, .green = 0.8f, .blue = 0.75f};
    return _color;
}
