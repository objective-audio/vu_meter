//
//  VUMeterViewController.h
//

#import <UIKit/UIKit.h>
#import "vu_main.hpp"

@interface VUMeterViewController : UIViewController

- (void)set_vu_main:(yas::vu::main_ptr_t)main;

@end
