Elm.Native.D3.Color = {};
Elm.Native.D3.Color.make = function(elm) {
  'use strict';

  elm.Native = elm.Native || {};
  elm.Native.D3 = elm.Native.D3 || {};
  elm.Native.D3.Color = elm.Native.D3.Color || {};
  if (elm.Native.D3.Color.values) return elm.Native.D3.Color.values;

  function elm_convert(typ) {
    return function(color) {
      return typeof color[typ] == 'function' ? color[typ]() : d3[typ](color);
    };
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

  // XXX: This belongs in the JavaScript FFI
  function elm_get(attr, object) {
    return object[attr];
  }

  return elm.Native.D3.Color.values = {
    fromRGB : F3(d3.rgb),
    toRGB : elm_convert('rgb'),
    fromHSL : F3(d3.hsl),
    toHSL : elm_convert('hsl'),
    fromHCL : F3(d3.hcl),
    toHCL : elm_convert('hcl'),
    fromLAB : F3(d3.lab),
    toLAB : elm_convert('lab'),
    brighter : F2(elm_brighter),
    darker : F2(elm_darker),
    fromString : d3.rgb,
    toString : elm_toString,

    get : F2(elm_get),
  };
};
