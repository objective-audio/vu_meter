//
//  yas_flow_observing.h
//

#pragma once

#include "yas_flow.h"
#include "yas_observing.h"

namespace yas {
template <typename Key, typename T>
flow::node<T, T, T> begin_flow(subject<Key, T> &subject, Key const &key) {
    flow::sender<T> sender;

    auto observer = subject.make_observer(key, [weak_sender = to_weak(sender)](auto const &context) mutable {
        if (auto sender = weak_sender.lock()) {
            sender.send_value(context.value);
        }
    });
    sender.set_observer(std::move(observer));

    return sender.begin_flow();
}
}
