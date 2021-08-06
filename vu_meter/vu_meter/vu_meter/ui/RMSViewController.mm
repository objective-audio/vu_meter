//
//  RMSViewController.mm
//

#import "RMSViewController.h"
#include "vu_main.hpp"
#include "vu_ui_color.hpp"

NS_ASSUME_NONNULL_BEGIN

using namespace yas;

namespace yas::vu {
struct rms_vc_cpp {
    vu::main_ptr_t const main = vu::main::make_shared();
    vu::ui_main_ptr_t ui_main;
};
}

@implementation RMSViewController {
    vu::rms_vc_cpp _cpp;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    if (NSClassFromString(@"XCTest")) {
        return;
    }

    self->_cpp.main->setup();
    self->_cpp.ui_main = vu::ui_main::make_shared();

    auto const metal_system = ui::metal_system::make_shared(
        objc_ptr_with_move_object(MTLCreateSystemDefaultDevice()).object(), self.metalView, 4);
    auto const standard = ui::standard::make_shared([self view_look], metal_system);

    self->_cpp.ui_main->setup(standard, self->_cpp.main);

    [self configure_with_metal_system:metal_system
                             renderer:standard->renderer()
                        event_manager:standard->event_manager()];
}

@end

NS_ASSUME_NONNULL_END
