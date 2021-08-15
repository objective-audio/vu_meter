//
//  RMSViewController.mm
//

#import "RMSViewController.h"
#include "vu_app.h"
#include "vu_main.hpp"
#include "vu_ui_color.hpp"

NS_ASSUME_NONNULL_BEGIN

using namespace yas;
using namespace yas::vu;

namespace yas::vu {
struct view_controller_cpp {
    std::shared_ptr<ui_main> ui_main = nullptr;
};
}

@implementation RMSViewController {
    view_controller_cpp _cpp;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    if (NSClassFromString(@"XCTest")) {
        return;
    }

    auto const metal_system = ui::metal_system::make_shared(
        objc_ptr_with_move_object(MTLCreateSystemDefaultDevice()).object(), self.metalView, 4);
    auto const ui_standard = ui::standard::make_shared([self view_look], metal_system);
    vu::app::shared()->set_ui_standard(ui_standard);

    self->_cpp.ui_main = ui_main::make_shared();

    [self configure_with_metal_system:metal_system
                             renderer:ui_standard->renderer()
                        event_manager:ui_standard->event_manager()];
}

@end

NS_ASSUME_NONNULL_END
