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
    vu::main_ptr_t main;
    vu::ui_main_ptr_t ui_main;

    bool needs_setup() const {
        return this->main && this->ui_main && this->ui_main->needs_setup();
    }
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

    self->_cpp.ui_main = vu::ui_main::make_shared();

    [self setup_if_needed];
}

- (void)set_vu_main:(vu::main_ptr_t)main {
    self->_cpp.main = main;

    [self setup_if_needed];
}

- (void)setup_if_needed {
    if (!self->_cpp.needs_setup()) {
        return;
    }

    auto renderer = ui::renderer::make_shared(
        ui::metal_system::make_shared(objc_ptr_with_move_object(MTLCreateSystemDefaultDevice()).object()));

    [self setRenderable:renderer];

    self->_cpp.ui_main->setup(renderer, self->_cpp.main);
}

@end

NS_ASSUME_NONNULL_END
