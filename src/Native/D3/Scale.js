Elm.Native.D3.Scale = {};
Elm.Native.D3.Scale.make = function (elm) {
    'use strict';

    elm.Native = elm.Native || {};
    elm.Native.D3 = elm.Native.D3 || {};
    elm.Native.D3.Scale = elm.Native.D3.Scale || {};
    if (elm.Native.D3.Scale.values) return elm.Native.D3.Scale.values;

    var JS = Elm.Native.D3.JavaScript.make(elm);

    function pow(exponent) {
        return d3.scale.pow().exponent(JS.toFloat(exponent));
    }

    function log(base) {
        return d3.scale.log().base(JS.toFloat(base));
    }

    function domain(domArray, scale) {
        var newScale = scale.copy();
        var newDomain = JS.fromList(domArray);
        return newScale.domain(newDomain);
    }

    function range(rangeArray, scale) {
        var newScale = scale.copy();
        var newRange = JS.fromList(rangeArray);
        return newScale.range(newRange);
    }

    function ticks(nTicks, scale) {
        var tempScale = scale.copy();
        return tempScale.ticks(JS.toInt(nTicks));
    }

    function nice(scale) {
        var newScale = scale.copy();
        return newScale.nice();
    }

    function clamp(bool, scale) {
        var newScale = scale.copy();
        return newScale.clamp(JS.toBool(bool));
    }

    function convert(n, scale) {
        var number = JS.toFloat(n);
        return scale(number);
    }

    function invert(n, scale) {
        var number = JS.toFloat(n);
        return scale.invert(number);
    }

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
