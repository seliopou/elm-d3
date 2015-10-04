Elm.Native.D3 = Elm.Native.D3 || {};
Elm.Native.D3.Color = {};
Elm.Native.D3.Color.make = function(elm) {
  'use strict';

  elm.Native = elm.Native || {};
  elm.Native.D3 = elm.Native.D3 || {};
  elm.Native.D3.Color = elm.Native.D3.Color || {};
  if (elm.Native.D3.Color.values) return elm.Native.D3.Color.values;

  function elm_create(typ, a, b, c) {
    return d3[typ](a, b, c);
  }

  function elm_convert(typ, color) {
    return typeof color[typ] == 'function' ? color[typ]() : d3[typ](color);
  }

  function elm_fromString(str) {
    return d3.rgb(str);
  }

  function elm_toString(color) {
    return color.toString();
  }

  function elm_brighter(amount, color) {
    return color.brighter(amount);
  }

  function elm_darker(amount, color) {
    return color.darker(amount);
  }

  return elm.Native.D3.Color.values = {
    create : F4(elm_create),
    convert : F2(elm_convert),
    brighter : F2(elm_brighter),
    darker : F2(elm_darker),
    fromString : elm_fromString,
    toString : elm_toString,
  };
};
