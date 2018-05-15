//
//  RMSViewController.mm
//

#import "RMSViewController.h"
#include "vu_main.hpp"
#include "vu_ui_color.hpp"

NS_ASSUME_NONNULL_BEGIN

using namespace yas;

@interface RMSViewController ()

@end

@implementation RMSViewController {
    vu::main_ptr_t _main;
    vu::ui_main ui_main;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    if (NSClassFromString(@"XCTest")) {
        return;
    }

    self.metalView.clearColor = vu::base_color();

    ui::renderer renderer{ui::metal_system{make_objc_ptr(MTLCreateSystemDefaultDevice()).object()}};

    [self setRenderable:renderer.view_renderable()];

    self->ui_main.setup(std::move(renderer), self->_main);
}

- (void)set_vu_main:(vu::main_ptr_t)main {
    self->_main = main;
}

@end

NS_ASSUME_NONNULL_END
