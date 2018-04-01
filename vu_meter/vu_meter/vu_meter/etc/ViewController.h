//
//  ViewController.h
//

#import <UIKit/UIKit.h>
#import "vu_main.hpp"
#import "vu_types.h"

@interface ViewController : UIViewController

- (void)set_vu_main:(yas::vu::main_ptr_t)main;

@end

