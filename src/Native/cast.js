function safeValfn(valfn, caster) {
  return typeof valfn == 'function'
    ? caster(valfn)
    : valfn;
};

function safeIndexed(i, valfn) {
  return typeof valfn == "function" && typeof i != "undefined"
    ? function(d, _) { return valfn.call(this, d, i); }
    : valfn;
}

function id(x) { return x; }
