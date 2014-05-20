import "../cast"

/* In Elm's 0.12.3 release, several casting functions were removed from the
 * Native.JavaScript module. To minimize the changes to the rest of the elm-d3
 * code, this module acts as drop-in replacement from the current
 * Native.JavaScript module as well as its pre-0.12.3 API as well.
 */
Elm.Native.D3.JavaScript = {};
Elm.Native.D3.JavaScript.make = function(elm) {
  'use strict';

  elm.Native = elm.Native || {};
  elm.Native.D3 = elm.Native.D3 || {};
  elm.Native.D3.JavaScript = elm.Native.D3.JavaScript || {};
  if (elm.Native.D3.JavaScript.values) return elm.Native.D3.JavaScript.values;

  var JS = Elm.Native.JavaScript.make(elm);
  var List = Elm.Native.List.make(elm);

  return elm.Native.D3.JavaScript.values = {
    toBool      : id,
    toFloat     : function (x) { return +x; },
    toInt       : function (x) { return x|0; },
    toList      : List.fromArray,
    toRecord    : JS.toRecord,
    toString    : id,
    fromBool    : id,
    fromFloat   : id,
    fromInt     : id,
    fromList    : List.toArray,
    fromRecord  : JS.fromRecord,
    fromString  : id
  };
};
