function safeValfn(valfn) {
  return typeof valfn == 'function'
    ? function(d, i) { return valfn(d)(i); }
    : valfn;
};
