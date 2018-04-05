//
//  vu_ui.mm
//

#include "vu_ui_main.hpp"
#include "vu_main.hpp"

using namespace yas;

void vu::ui_main::setup(main_ptr_t &main) {
    weak_main_ptr_t weak_main = main;

    ui::texture texture{{.point_size = {1024, 1024}}};
    texture.observe_scale_from_renderer(this->renderer);

    ui::node &root_node = this->renderer.root_node();
    root_node.add_sub_node(this->reference.node);

    this->reference.setup(main, texture);

    float const offset = this->renderer.safe_area_layout_guide_rect().region().size.width / 4.0f;
    for (auto const &idx : {0, 1}) {
        auto &indicator = this->indicators.at(idx);
        root_node.add_sub_node(indicator.node);
        indicator.setup(main, idx);
#warning todo ちゃんとviewのサイズから算出する
        indicator.layout(100.0f, texture);

        indicator.node.set_position({.x = (idx == 0 ? -offset : offset)});
    }

    this->_renderer_observer = this->renderer.subject().make_observer(ui::renderer::method::will_render,
                                                                      [this, weak_main](auto const &context) {
                                                                          for (auto &indicator : this->indicators) {
                                                                              indicator.update();
                                                                          }
                                                                      });
}
