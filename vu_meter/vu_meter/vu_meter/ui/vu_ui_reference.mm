//
//  vu_ui_reference.mm
//

#include "vu_ui_reference.hpp"

using namespace yas;

void vu::ui_reference::setup(ui::texture &texture) {
    this->minus_button.rect_plane().node().set_position({.x = -100.0f});
    this->node.add_sub_node(this->minus_button.rect_plane().node());

    this->plus_button.rect_plane().node().set_position({.x = 100.0f});
    this->node.add_sub_node(this->plus_button.rect_plane().node());

    this->font_atlas = ui::font_atlas{
        {.font_name = "AmericanTypewriter-Bold", .font_size = 20.0f, .words = "0123456789.dB-", .texture = texture}};

    this->text =
        ui::strings{{.max_word_count = 10, .font_atlas = this->font_atlas, .alignment = ui::layout_alignment::mid}};
    this->node.add_sub_node(this->text.rect_plane().node());
}
