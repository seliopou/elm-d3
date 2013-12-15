function safeValfn(valfn, caster) {
  return typeof valfn == 'function'
    ? caster(valfn)
    : valfn;
};
