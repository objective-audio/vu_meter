//
//  VUMeterViewController.mm
//

#import "VUMeterViewController.h"

using namespace yas;

@interface VUMeterViewController ()

@end

@implementation VUMeterViewController {
    vu::main_ptr_t _main;
    std::size_t _idx;
}

- (void)set_vu_main:(vu::main_ptr_t)main index:(std::size_t)idx {
    self->_main = main;
    self->_idx = idx;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

@end
