//
//  RMSViewController.mm
//

#import "RMSViewController.h"
#include "vu_ui_color.hpp"
#include "vu_main.hpp"

NS_ASSUME_NONNULL_BEGIN

using namespace yas;

@interface RMSViewController ()

@end

@implementation RMSViewController {
    vu::main_ptr_t _main;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.metalView.clearColor = vu::base_color();

    [self setRenderable:self->_main->ui_main.renderer.view_renderable()];

    self->_main->ui_main.setup(self->_main);
}

- (void)set_vu_main:(vu::main_ptr_t)main {
    self->_main = main;
}

@end

NS_ASSUME_NONNULL_END
