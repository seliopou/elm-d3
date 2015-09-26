Elm.Native.D3 = Elm.Native.D3 || {};
Elm.Native.D3.Voronoi = {};
Elm.Native.D3.Voronoi.make = function(elm) {
  'use strict';

  elm.Native = elm.Native || {};
  elm.Native.D3 = elm.Native.D3 || {};
  elm.Native.D3.Voronoi = elm.Native.D3.Voronoi || {};
  if (elm.Native.D3.Voronoi.values) return elm.Native.D3.Voronoi.values;

  var JS = Elm.Native.D3.JavaScript.make(elm);

  var voronoi = d3.geom.voronoi()
      .x(function(d) { return d.x; })
      .y(function(d) { return d.y; });

  function mk_cells(v, ps) {
    ps = JS.fromList(ps);
    return JS.toList(v(ps.map(JS.fromRecord)).map(function(c) {
      return JS.toList(c.map(function(p) {
        return JS.toRecord({ x : JS.toFloat(p[0]), y : JS.toFloat(p[1]) });
      }));
    }));
  }

  function elm_cells(ps) {
    return mk_cells(voronoi, ps);
  }

  function elm_cellsWithClipping(x, y, w, h, ps) {
    x = JS.fromFloat(x);
    y = JS.fromFloat(y);
    w = JS.fromFloat(w);
    h = JS.fromFloat(h);

    return mk_cells(voronoi.clipExtent([[x, y], [w, h]]), ps);
  }

  return elm.Native.D3.Voronoi.values = {
    cells: elm_cells,
    cellsWithClipping : F5(elm_cellsWithClipping)
  };
};
