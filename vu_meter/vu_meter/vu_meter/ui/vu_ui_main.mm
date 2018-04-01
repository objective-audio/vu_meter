//
//  vu_ui.mm
//

#include "vu_ui_main.hpp"
#include "vu_main.hpp"

using namespace yas;

void vu::ui_main::setup(main_ptr_t &main) {
    ui::node &root_node = this->renderer.root_node();
    root_node.add_sub_node(this->reference.node);

    ui::texture texture{{.point_size = {1024, 1024}}};
    texture.observe_scale_from_renderer(this->renderer);

    this->reference.setup(main, texture);
}
