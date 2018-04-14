//
//  yas_flow.h
//

#pragma once

#include "yas_base.h"
#include "yas_any.h"
#include <functional>

namespace yas::flow {
template <typename Out, typename In, typename Begin>
struct node;

template <typename T>
struct sender : base {
    class impl;

    sender();
    sender(std::nullptr_t);

    void set_value(T const &);

    node<T, T, T> make_flow();

    // observer
    void set_observer(base);
    // keeper
    template <typename P>
    void push_handler(std::function<void(P const &)>);
    std::size_t handlers_size() const;
    template <typename P>
    std::function<void(P const &)> const &handler(std::size_t const) const;
};

template <typename Out, typename In, typename Begin>
struct node : base {
    class impl;

    node(sender<Begin>);
    // private
    node(sender<Begin>, std::function<Out(In)>);
    node(std::nullptr_t);

    node<Out, In, Begin> execute(std::function<void(In)>);

    template <typename Next = Out>
    node<Next, In, Begin> change(std::function<Next(In)>);

    node<Out, Out, Begin> wait(double const);

    node<std::nullptr_t, In, Begin> end();
};
}

#include "yas_flow_private.h"
