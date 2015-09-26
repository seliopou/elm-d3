/* In Elm's 0.12.3 release, several casting functions were removed from the
 * Native.JavaScript module. To minimize the changes to the rest of the elm-d3
 * code, this module acts as drop-in replacement from the current
 * Native.JavaScript module as well as its pre-0.12.3 API as well.
 *
 * In elm's 0.15.1 release, all the JavaScript native casting functions were
 * removed. To ease porting to this version, the removed functions (fromJS, toJS,
 * etc.) have been copied below.
 */
Elm.Native.D3 = Elm.Native.D3 || {};
Elm.Native.D3.JavaScript = {};
Elm.Native.D3.JavaScript.make = function(elm) {
  'use strict';

  elm.Native = elm.Native || {};
  elm.Native.D3 = elm.Native.D3 || {};
  elm.Native.D3.JavaScript = elm.Native.D3.JavaScript || {};
  if (elm.Native.D3.JavaScript.values) return elm.Native.D3.JavaScript.values;

  var List = Elm.Native.List.make(elm);

  function fromJS(v) {
      var type = typeof v;
      if (type === 'number' ) return v;
      if (type === 'boolean') return v;
      if (type === 'string' ) return v;
      if (v instanceof Array) {
          var arr = [];
          var len = v.length;
          for (var i = 0; i < len; ++i) {
              var x = fromJS(v[i]);
              if (x !== null) arr.push(x);
          }
          return List.fromArray(arr);
      }
      if (type === 'object') {
          var rec = { _:{} };
          for (var f in v) {
              var x = fromJS(v[f]);
              if (x !== null) rec[f] = x;
          }
          return rec;
      }
      return null;
  }

  function toJS(v) {
      var type = typeof v;
      if (type === 'number' || type === 'boolean' || type === 'string') return v;
      if (type === 'object' && '_' in v) {
          var obj = {};
          for (var k in v) {
              var x = toJS(v[k]);
              if (x !== null) obj[k] = x;
          }
          return obj;
      }
      if (type === 'object' && (v.ctor === '::' || v.ctor === '[]')) {
          var array = List.toArray(v);
          for (var i = array.length; i--; ) {
              array[i] = toJS(array[i]);
          }
          return array;
      }
      return null;
  }

  function fromRecord(r) {
      if (typeof r === 'object' && '_' in r) {
          return toJS(r);
      }
      throw "'fromRecord' must be called on a record.";
  }

  function id(x) { return x; }

  return elm.Native.D3.JavaScript.values = {
    toBool      : id,
    toFloat     : function (x) { return +x; },
    toInt       : function (x) { return x|0; },
    toList      : List.fromArray,
    toRecord    : fromJS,
    toString    : id,
    fromBool    : id,
    fromFloat   : id,
    fromInt     : id,
    fromList    : List.toArray,
    fromRecord  : fromRecord,
    fromString  : id,
    toJS        : toJS,
    fromJS      : fromJS
  };
};
