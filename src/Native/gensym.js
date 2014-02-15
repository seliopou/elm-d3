var gensym = (function() {
  var i = 0;
  return function(str) {
    return str + (++i);
  };
})();
