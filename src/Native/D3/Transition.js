Elm.Native.D3 = Elm.Native.D3 || {};
Elm.Native.D3.Transition = {};
Elm.Native.D3.Transition.make = function(elm) {
  'use strict';

  elm.Native = elm.Native || {};
  elm.Native.D3 = elm.Native.D3 || {};
  elm.Native.D3.Transition = elm.Native.D3.Transition || {};
  if (elm.Native.D3.Transition.values) return elm.Native.D3.Transition.values;

  var JS = Elm.Native.D3.JavaScript.make(elm);
  var Util = Elm.Native.D3.Util.make(elm);
  var safeIndexed = Util.__native__.safeIndexed,
      safeValfn   = Util.__native__.safeValfn;


  function safeTransition(fn) {
    return function (a, i) {
      return JS.fromInt(A2(fn, a, JS.toInt(i)));
    };
  }

  function elm_transition(k, selection, i) {
    return k(selection.transition(), i);
  }

  function elm_delay(valfn) {
    valfn = safeValfn(valfn, safeTransition);
    return function(k, selection, i) {
      return k(selection.delay(safeIndexed(i, valfn)), i);
    };
  }

  function elm_duration(valfn) {
    valfn = safeValfn(valfn, safeTransition);
    return function(k, selection, i) {
      return k(selection.duration(safeIndexed(i, valfn)), i);
    };
  }

  return elm.Native.D3.Transition.value = {
    transition : elm_transition,
    delay: elm_delay,
    duration : elm_duration
  };
};
