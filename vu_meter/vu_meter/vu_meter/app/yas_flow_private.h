//
//  yas_flow_private.h
//

#pragma once

#include "yas_timer.h"
#include <vector>

namespace yas::flow {
template <typename T>
struct sender<T>::impl : base::impl {
    std::vector<yas::any> _handlers;
    base _observer = nullptr;

    void set_value(T const &value) {
        if (this->_handlers.size() > 0) {
            this->_handlers.front().template get<std::function<void(T const &)>>()(value);
        }
    }
};

template <typename T>
sender<T>::sender() : base(std::make_shared<impl>()) {
}

template <typename T>
sender<T>::sender(std::nullptr_t) : base(nullptr) {
}

template <typename T>
void sender<T>::set_value(T const &value) {
    impl_ptr<impl>()->set_value(value);
}

template <typename T>
node<T, T, T> sender<T>::make_flow() {
    return node<T, T, T>(*this);
}

template <typename T>
void sender<T>::set_observer(base observer) {
    impl_ptr<impl>()->_observer = std::move(observer);
}

template <typename T>
template <typename P>
void sender<T>::push_handler(std::function<void(P const &)> handler) {
    impl_ptr<impl>()->_handlers.push_back(handler);
}

template <typename T>
std::size_t sender<T>::handlers_size() const {
    return impl_ptr<impl>()->_handlers.size();
}

template <typename T>
template <typename P>
std::function<void(P const &)> const &sender<T>::handler(std::size_t const idx) const {
    return impl_ptr<impl>()->_handlers.at(idx).template get<std::function<void(P const &)>>();
}

#pragma mark -

template <typename Out, typename In, typename Begin>
struct node<Out, In, Begin>::impl : base::impl {
    impl(sender<Begin> &&sender, std::function<Out(In)> &&handler)
        : _sender(std::move(sender)), _handler(std::move(handler)) {
    }

    sender<Begin> _sender;
    std::function<Out(In)> _handler;
};

template <typename Out, typename In, typename Begin>
node<Out, In, Begin>::node(sender<Begin> sender) : node(std::move(sender), [](Begin value) { return value; }) {
}

template <typename Out, typename In, typename Begin>
node<Out, In, Begin>::node(sender<Begin> sender, std::function<Out(In)> handler)
    : base(std::make_shared<impl>(std::move(sender), std::move(handler))) {
}

template <typename Out, typename In, typename Begin>
node<Out, In, Begin>::node(std::nullptr_t) : base(nullptr) {
}

template <typename Out, typename In, typename Begin>
node<Out, In, Begin> node<Out, In, Begin>::execute(std::function<void(In)> exe_handler) {
    auto imp = impl_ptr<impl>();
    return node<Out, In, Begin>(
        std::move(imp->_sender),
        [exe_handler = std::move(exe_handler), handler = std::move(imp->_handler)](In const &value) {
            Out result = handler(value);
            exe_handler(result);
            return result;
        });
}

template <typename Out, typename In, typename Begin>
template <typename Next>
node<Next, In, Begin> node<Out, In, Begin>::change(std::function<Next(In)> change_handler) {
    auto imp = impl_ptr<impl>();
    return node<Next, In, Begin>(std::move(imp->_sender), [
        change_handler = std::move(change_handler), handler = std::move(imp->_handler)
    ](In const &value) { return change_handler(handler(value)); });
}

template <typename Out, typename In, typename Begin>
node<Out, Out, Begin> node<Out, In, Begin>::wait(double const time_interval) {
    auto imp = impl_ptr<impl>();
    flow::sender<Begin> &sender = imp->_sender;
    auto weak_sender = to_weak(sender);
    std::size_t const next_idx = sender.handlers_size() + 1;

    sender.template push_handler<In>([
        handler = imp->_handler, time_interval, weak_sender, next_idx, timer = yas::timer{nullptr}
    ](In const &value) mutable {
        timer = yas::timer(time_interval, false, [value = handler(value), weak_sender, next_idx]() {
            if (auto sender = weak_sender.lock()) {
                sender.template handler<Out>(next_idx)(value);
            }
        });
    });

    return node<Out, Out, Begin>(sender, [](Out const &value) { return value; });
}

template <typename Out, typename In, typename Begin>
node<std::nullptr_t, In, Begin> node<Out, In, Begin>::end() {
    auto &sender = impl_ptr<impl>()->_sender;
    sender.template push_handler<In>([handler = impl_ptr<impl>()->_handler](In const &value) { handler(value); });
    return node<std::nullptr_t, In, Begin>(std::move(sender), [](In const &) { return nullptr; });
}
}
