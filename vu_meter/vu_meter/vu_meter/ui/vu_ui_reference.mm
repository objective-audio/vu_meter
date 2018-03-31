//
//  vu_ui_reference.mm
//

#include "vu_ui_reference.hpp"
#include "vu_main.hpp"
#include "yas_fast_each.h"

using namespace yas;

void vu::ui_reference::setup(main &main, ui::texture &texture) {
    ui::uint_size button_size{60, 60};

    this->minus_button.rect_plane().node().mesh().set_texture(texture);
    this->minus_button.rect_plane().node().set_position({.x = -100.0f});
    this->node.add_sub_node(this->minus_button.rect_plane().node());

    for (auto const is_tracking : {false, true}) {
        auto draw_handler = [button_size, is_tracking](CGContextRef const ctx) {
            auto color =
                make_objc_ptr([[UIColor alloc] initWithRed:1.0 green:1.0 blue:0.0 alpha:is_tracking ? 1.0 : 0.5]);
            CGContextSetFillColorWithColor(ctx, color.object().CGColor);
            CGContextFillEllipseInRect(ctx, CGRectMake(0.0, 0.0, button_size.width, button_size.height));
        };
        auto element = texture.add_draw_handler(button_size, std::move(draw_handler));
        this->minus_button.rect_plane().data().observe_rect_tex_coords(element, to_rect_index(0, is_tracking));
    }

    this->plus_button.rect_plane().node().mesh().set_texture(texture);
    this->plus_button.rect_plane().node().set_position({.x = 100.0f});
    this->node.add_sub_node(this->plus_button.rect_plane().node());

    for (auto const is_tracking : {false, true}) {
        auto draw_handler = [button_size, is_tracking](CGContextRef const ctx) {
            auto color =
                make_objc_ptr([[UIColor alloc] initWithRed:1.0 green:0.0 blue:1.0 alpha:is_tracking ? 1.0 : 0.5]);
            CGContextSetFillColorWithColor(ctx, color.object().CGColor);
            CGContextFillEllipseInRect(ctx, CGRectMake(0.0, 0.0, button_size.width, button_size.height));
        };
        auto element = texture.add_draw_handler(button_size, std::move(draw_handler));
        this->plus_button.rect_plane().data().observe_rect_tex_coords(element, to_rect_index(0, is_tracking));
    }

    this->font_atlas = ui::font_atlas{
        {.font_name = "AmericanTypewriter-Bold", .font_size = 20.0f, .words = "0123456789.dB-", .texture = texture}};

    this->text =
        ui::strings{{.max_word_count = 10, .font_atlas = this->font_atlas, .alignment = ui::layout_alignment::mid}};
    this->node.add_sub_node(this->text.rect_plane().node());
}
