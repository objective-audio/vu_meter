//
//  RMSViewController.h
//

#import <UIKit/UIKit.h>
#import <ui/yas_ui_metal_view_controller.h>
#import "vu_types.h"

NS_ASSUME_NONNULL_BEGIN

@interface RMSViewController : YASUIMetalViewController

- (void)set_vu_main:(yas::vu::main_ptr_t)main;

@end

NS_ASSUME_NONNULL_END
