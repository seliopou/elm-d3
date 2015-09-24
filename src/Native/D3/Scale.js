Elm.Native.D3 = Elm.Native.D3 || {};
Elm.Native.D3.Scale = {};
Elm.Native.D3.Scale.make = function (elm) {
    'use strict';

    elm.Native = elm.Native || {};
    elm.Native.D3 = elm.Native.D3 || {};
    elm.Native.D3.Scale = elm.Native.D3.Scale || {};
    if (elm.Native.D3.Scale.values) return elm.Native.D3.Scale.values;

    var JS = Elm.Native.D3.JavaScript.make(elm);

    function pow(k) { return d3.scale.pow().exponent(JS.toFloat(k)); }
    function log(k) { return d3.scale.log().base(JS.toFloat(k)); }

    function domain(d, s) {
      return s.copy().domain(JS.fromList(d));
    }

    function range(d, s) {
      return s.copy().range(JS.fromList(d));
    }

    function ticks(s, n) {
      return s.copy().ticks(JS.toInt(n));
    }

    function tickFormat(s, f) {
      var g = function(x) { return JS.fromString(f(x)); };
      return s.copy().tickformat(g);
    }

    function nice(s) {
      return s.copy().nice();
    }

    function clamp(b, s) {
      return s.copy().clamp(JS.toBool(b));
    }

    function convert(s, n) { return s(JS.toFloat(n)); }
    function invert(s, n) { return s.invert(JS.toFloat(n)); }

    return elm.Native.D3.Scale.values =
        { linear : d3.scale.linear()
        , identity : d3.scale.identity()
        , sqrt : d3.scale.sqrt()
        , pow : pow
        , log : log
        , nice : nice
        , clamp : F2(clamp)
        , domain : F2(domain)
        , range : F2(range)
        , ticks : F2(ticks)
        , convert : F2(convert)
        , invert : F2(invert)
        };
};
