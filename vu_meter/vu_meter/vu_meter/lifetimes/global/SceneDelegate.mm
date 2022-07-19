//
//  SceneDelegate.m
//

#import "SceneDelegate.h"
#include "vu_app_lifetime.hpp"
#include "vu_audio_device.hpp"
#include "vu_lifetime_accessor.hpp"

using namespace yas;
using namespace vu;

@interface SceneDelegate ()

@end

@implementation SceneDelegate {
    std::weak_ptr<audio_device> _audio_device;
}

- (void)scene:(UIScene *)scene
    willConnectToSession:(UISceneSession *)session
                 options:(UISceneConnectionOptions *)connectionOptions {
    if (auto const &app_lifetime = lifetime_accessor::app_lifetime()) {
        self->_audio_device = app_lifetime->audio_device;
    }
}

- (void)sceneDidDisconnect:(UIScene *)scene {
    self->_audio_device.reset();
}

- (void)sceneDidBecomeActive:(UIScene *)scene {
    if (auto const audio_device = self->_audio_device.lock()) {
        audio_device->did_become_active();
    }
}

- (void)sceneWillResignActive:(UIScene *)scene {
}

- (void)sceneWillEnterForeground:(UIScene *)scene {
}

- (void)sceneDidEnterBackground:(UIScene *)scene {
}

@end
