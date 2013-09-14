Elm.Native.D3 = Elm.Native.D3 || {};
Elm.Native.D3.Selection = Elm.Native.D3.Selection || {};
Elm.Native.D3.Selection.make = function(elm) {
  'use strict';

  /*
   * A Brief Explanation of What's Going On
   *
   * At the core of D3 is the concept of a selection—a collection of DOM
   * elements to which you can associate data and apply transformations,
   * filters, and subselections. Some of these operations mutate elements in
   * the selection, while others create distinct subselections. The user
   * combines operations using either method chaining or sequence statements in
   * JavaScript, i.e., the semicolon.
   *
   * A selection encapsulates some state, operations transform that state and
   * then return to some implicit context that will apply further operations to
   * the selection. In other words an operation returns to some continuation.
   * This code models that pattern explicitly. A `Selection a` is a function
   * that takes a continuation and a selection, performs some stateful
   * operations to the selection, possibly creating a new one even, and then
   * passing that to the continuation. You can think of `Selection a` as being
   * an alias for a type that looks something like this:
   *
   *   (d3.selection -> d3.selectiond) -> d3.selection -> d3.selection
   *
   * This approach ensures that all operations that produce `Selection a`s are
   * pure functions. All effects are encapsulated in closures and deferred
   * until the Elm runtime decides that the `Selection a` should be rendered or
   * updated. In order to make the Elm runtime aware of the `Selection a`, you
   * have to turn it into an `Element` by calling the `render` function. You
   * can find the render function in the D3 Elm module. See Native/D3/Render.js
   * for its implementation.
   */

  elm.Native = elm.Native || {};
  elm.Native.D3 = elm.Native.D3 || {};
  elm.Native.D3.Selection = elm.Native.D3.Selection || {};
  if (elm.Native.D3.Selection.values) return elm.Native.D3.Selection.values;

  function id(x) { return x; }

  function safeValfn(valfn) {
    return typeof valfn == 'function'
      ? function(d, i) { return valfn(d)(i); }
      : valfn;
  };

  function elm_sequence(s1, s2) {
    return function(k, selection) {
      s1(id, selection);
      s2(id, selection);
      return k(selection);
    };
  }

  function elm_chain(s1, s2) {
    return function(k, selection) {
      return s1(function(_selection) {
        return s2(k, _selection);
      }, selection);
    };
  }

  function elm_select(selector) {
    return function(k, selection) {
      return k(selection.select(selector));
    };
  }

  function elm_selectAll(selector) {
    return function(k, selection) {
      return k(selection.selectAll(selector));
    };
  }

  function elm_append(element) {
    return function(k, selection) {
      return k(selection.append(element));
    };
  }

  function elm_bind(fn, enter, update, exit) {
    return function(k, selection) {
      var bind  = selection.data(fn);

      enter(id, bind.enter());
      update(id, bind);
      exit(id, bind.exit());

      return k(selection);
    };
  }

  function elm_enter(k, selection) {
    return k(selection.enter());
  }

  function elm_exit(k, selection) {
    return k(selection.exit());
  }

  function elm_update(k, selection) {
    return k(selection);
  }

  function elm_remove(k, selection) {
    return k(selection.remove());
  }

  function elm_classed(name, valfn) {
    valfn = safeValfn(valfn);
    return function(k, selection) {
      return k(selection.classed(name, valfn));
    };
  }

  function elm_attr(name, valfn) {
    valfn = safeValfn(valfn);
    return function(k, selection) {
      return k(selection.attr(name, valfn));
    };
  }

  function elm_style(name, valfn) {
    valfn = safeValfn(valfn);
    return function(k, selection) {
      return k(selection.style(name, valfn));
    };
  }

  function elm_property(name, valfn) {
    valfn = safeValfn(valfn);
    return function(k, selection) {
      return k(selection.property(name, valfn));
    };
  }

  function elm_html(valfn) {
    valfn = safeValfn(valfn);
    return function(k, selection) {
      return k(selection.html(valfn));
    };
  }

  function elm_text(valfn) {
    valfn = safeValfn(valfn);
    return function(k, selection) {
      return k(selection.text(valfn));
    };
  }

  return elm.Native.D3.values = {
    version : d3.version,
    sequence : F2(elm_sequence),
    chain : F2(elm_chain),
    select : elm_select,
    selectAll : elm_selectAll,
    append : elm_append,
    bind : F4(elm_bind),
    enter : elm_enter,
    exit : elm_exit,
    update : elm_update,
    remove : elm_remove,
    classed : F2(elm_classed),
    attr : F2(elm_attr),
    style : F2(elm_style),
    property : F2(elm_property),
    html : elm_html,
    text : elm_text
  };
};
