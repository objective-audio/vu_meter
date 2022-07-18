//
//  RMSViewController.mm
//

#import "RMSViewController.h"
#include "vu_app_lifetime.hpp"
#include "vu_lifetime_accessor.hpp"
#include "vu_ui_lifecycle.hpp"
#include "vu_ui_lifetime.hpp"
#include "vu_ui_main.hpp"

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

    lifetime_accessor::app_lifetime()->ui_lifecycle->add_lifetime(ui_standard);

    self->_cpp.ui_main = ui_main::make_shared();

    [self configure_with_metal_system:metal_system
                             renderer:ui_standard->renderer()
                        event_manager:ui_standard->event_manager()];
}

@end

NS_ASSUME_NONNULL_END
