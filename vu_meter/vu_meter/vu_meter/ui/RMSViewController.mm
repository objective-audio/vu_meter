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

@implementation RMSViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if (NSClassFromString(@"XCTest")) {
        return;
    }

    auto const &app = vu::app::shared();

    auto const metal_system = ui::metal_system::make_shared(
        objc_ptr_with_move_object(MTLCreateSystemDefaultDevice()).object(), self.metalView, 4);
    app->ui_standard = ui::standard::make_shared([self view_look], metal_system);
    app->ui_main = vu::ui_main::make_shared();

    [self configure_with_metal_system:metal_system
                             renderer:app->ui_standard->renderer()
                        event_manager:app->ui_standard->event_manager()];
}

@end

NS_ASSUME_NONNULL_END
