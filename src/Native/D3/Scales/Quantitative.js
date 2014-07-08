Elm.Native.D3.Scales.Quantitative = {};
Elm.Native.D3.Scales.Quantitative.make = function (elm) {
    'use strict';

    elm.Native = elm.Native || {};
    elm.Native.D3 = elm.Native.D3 || {};
    elm.Native.D3.Scales = elm.Native.D3.Scales || {};
    elm.Native.D3.Scales.Quantitative = elm.Native.D3.Scales.Quantitative || {};
    if (elm.Native.D3.Scales.Quantitative.values) return elm.Native.D3.Scales.Quantitative.values;

    var JS = Elm.Native.D3.JavaScript.make(elm);


    function scale(scaleADT) {
        var lowerDomainBound = JS.toFloat(scaleADT.domain._0);
        var upperDomainBound = JS.toFloat(scaleADT.domain._1);
        var lowerRangeBound = JS.toFloat(scaleADT.range._0);
        var upperRangeBound = JS.toFloat(scaleADT.range._1);
        var kind = d3.scale;
        if(scaleADT.kind.ctor === 'Linear') {
            kind = kind.linear();
        } else if(scaleADT.kind.ctor === 'Power') {
            var exponent = JS.toFloat(scaleADT.kind._0);
            kind = kind.pow(exponent);
        } else if(scaleADT.kind.ctor === 'Log') {
            var exponent = JS.toFloat(scaleADT.kind._0);
            kind = kind.log(exponent);
        }
        return kind.domain([lowerDomainBound, upperDomainBound])
                   .range([lowerRangeBound, upperRangeBound]);
    }

    function linear() {
        return d3.scale.linear();
    }

    function identity() {
        return d3.scale.identity();
    }

    function pow(exponent) {
        var exp = JS.toFloat(exponent);
        return d3.scale.pow().exponent(exp);
    }

    function sqrt() {
        return d3.scale.sqrt();
    }

    function log(base) {
        var logBase = JS.toFloat(base);
        return d3.scale.log.base(logBase);
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

    function clamp(scale) {
        var newScale = scale.copy();
        return newScale.clamp(true);
    }

    function convert(n, scale) {
        var number = JS.toFloat(n);
        return scale(number);
    }

    function invert(n, scale) {
        var number = JS.toFloat(n);
        return scale.invert(number);
    }

    return elm.Native.D3.Scales.Quantitative.values =
        { toFunction : scale
        , linear : linear()
        , identity : identity()
        , sqrt : sqrt()
        , pow : pow
        , log : log
        , nice : nice
        , clamp : clamp
        , domain : F2(domain)
        , range : F2(range)
        , ticks : F2(ticks)
        , convert : F2(convert)
        , invert : F2(invert)
        };
};
