//
//  RMSViewController.mm
//

#import "RMSViewController.h"
#include <ui/yas_ui_umbrella.h>
#include "vu_app_lifetime.hpp"
#include "vu_lifetime_accessor.hpp"
#include "vu_ui_lifecycle.hpp"
#include "vu_ui_lifetime.hpp"

NS_ASSUME_NONNULL_BEGIN

using namespace yas;
using namespace yas::vu;

@implementation RMSViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if (NSClassFromString(@"XCTest")) {
        return;
    }

    auto const metal_system = ui::metal_system::make_shared(
        objc_ptr_with_move_object(MTLCreateSystemDefaultDevice()).object(), self.metalView, 4);
    auto const standard = ui::standard::make_shared([self view_look], metal_system);

    lifetime_accessor::app_lifetime()->ui_lifecycle->add_lifetime(standard);

    [self configure_with_metal_system:metal_system
                             renderer:standard->renderer()
                        event_manager:standard->event_manager()];
}

@end

NS_ASSUME_NONNULL_END
