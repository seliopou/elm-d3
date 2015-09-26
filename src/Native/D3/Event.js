Elm.Native.D3 = Elm.Native.D3 || {};
Elm.Native.D3.Event = {};
Elm.Native.D3.Event.make = function(elm) {
  'use strict';

  elm.Native = elm.Native || {};
  elm.Native.D3 = elm.Native.D3 || {};
  elm.Native.D3.Event = elm.Native.D3.Event || {};

  if (elm.Native.D3.Event.values) return elm.Native.D3.Event.values;

  var JS = Elm.Native.D3.JavaScript.make(elm);
  var Util = Elm.Native.D3.Util.make(elm);
  var safeIndexed = Util.__native__.safeIndexed;

  function mouse_event() {
    return JS.toRecord({
      altKey : d3.event.altKey,
      button : d3.event.button,
      ctrlKey : d3.event.ctrlKey,
      metaKey : d3.event.metaKey,
      shiftKey : d3.event.shiftKey
    });
  }

  function keyboard_event() {
    return JS.toRecord({
      altKey : d3.event.altKey,
      keyCode : d3.event.keyCode,
      ctrlKey : d3.event.ctrlKey,
      metaKey : d3.event.metaKey,
      shiftKey : d3.event.shiftKey
    });
  }

  function elm_handle_mouse(_event, signal, fn) {
    return function(k, selection, i) {
      return k(selection.on(_event, safeIndexed(i, function(d, i) {
        return elm.notify(signal.id, A3(fn, mouse_event(), d, JS.toInt(i)));
      })), i);
    };
  }

  function elm_handle_keyboard(_event, signal, fn) {
    return function(k, selection, i) {
      return k(selection.on(_event, safeIndexed(i, function(d, i) {
        return elm.notify(signal.id, A3(fn, keyboard_event(), d, JS.toInt(i)));
      })), i);
    };
  }

  function elm_handle_input(signal, fn) {
    return function(k, selection, i) {
      return k(selection.on('input', safeIndexed(i, function(d, i) {
        var value = d3.select(this).node().value;
        return elm.notify(signal.id, A3(fn, JS.toString(value), d, JS.toInt(i)));
      })), i);
    };
  }

  function elm_handle_focus(signal, fn) {
    return function(k, selection, i) {
      return k(selection.on('focus', safeIndexed(i, function(d, i) {
        return elm.notify(signal.id, A2(fn, d, JS.toInt(i)));
      })), i);
    }
  }

  function elm_handle_blur(signal, fn) {
    return function(k, selection, i) {
      return k(selection.on('blur', safeIndexed(i, function(d, i) {
        return elm.notify(signal.id, A2(fn, d, JS.toInt(i)));
      })), i);
    }
  }

  return elm.Native.D3.Event.values = {
    handleMouse : F3(elm_handle_mouse),
    handleKeyboard : F3(elm_handle_keyboard),
    handleInput : F2(elm_handle_input),
    handleFocus : F2(elm_handle_focus),
    handleBlur : F2(elm_handle_blur)
  };
};
