//
//  RMSViewController.mm
//

#import "RMSViewController.h"
#include <ui/yas_ui_umbrella.h>
#include <vu-meter-core/lifetimes/app/app_lifetime.hpp>
#include <vu-meter-core/lifetimes/global/lifetime_accessor.hpp>
#include <vu-meter-core/lifetimes/app/lifecycles/ui_lifecycle.hpp>
#include <vu-meter-core/lifetimes/ui/ui_lifetime.hpp>

NS_ASSUME_NONNULL_BEGIN

using namespace yas;
using namespace yas::vu;

@implementation RMSViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

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
