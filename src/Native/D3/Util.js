Elm.Native.D3 = Elm.Native.D3 || {};
Elm.Native.D3.Util = {};
Elm.Native.D3.Util.make = function(elm) {
  'use strict';

  elm.Native = elm.Native || {};
  elm.Native.D3 = elm.Native.D3 || {};
  elm.Native.D3.Util = elm.Native.D3.Util || {};
  if (elm.Native.D3.Util.values) return elm.Native.D3.Util.values;

  function safeValfn(valfn, caster) {
    return typeof valfn == 'function'
      ? caster(valfn)
      : valfn;
  };

  function safeIndexed(i, valfn) {
    return typeof valfn == "function" && typeof i != "undefined"
      ? function(d, _) { return valfn.call(this, d, i); }
      : valfn;
  }

  var gensym = (function() {
    var i = 0;
    return function(str) {
      return str + (++i);
    };
  })();

  return elm.Native.D3.Util.values = {
    __native__ : {
      safeValfn : safeValfn,
      safeIndexed : safeIndexed,
      gensym : gensym
    }
  };
};
