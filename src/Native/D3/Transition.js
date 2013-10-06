import "../cast"

Elm.Native.D3.Transition = {};
Elm.Native.D3.Transition.make = function(elm) {
  'use strict';

  elm.Native = elm.Native || {};
  elm.Native.D3 = elm.Native.D3 || {};
  elm.Native.D3.Transition = elm.Native.D3.Transition || {};
  if (elm.Native.D3.Transition.values) return elm.Native.D3.Transition.values;

  function elm_transition(k, selection) {
    return k(selection.transition());
  }

  function elm_delay(valfn) {
    valfn = safeValfn(valfn);
    return function(k, selection) {
      return k(selection.delay(valfn));
    };
  }

  function elm_duration(valfn) {
    valfn = safeValfn(valfn);
    return function(k, selection) {
      return k(selection.duration(valfn));
    };
  }

  return elm.Native.D3.Transition.value = {
    transition : elm_transition,
    delay: elm_delay,
    duration : elm_duration
  };
};
