// Header/utility functions for sql.pegjs grammar match bodies.
//
function append(arr, x) {
    arr[arr.length] = x;
    return arr;
}

function flatten(x, rejectSpace, acc) {
    acc = acc || [];
    if (x == null || x == undefined) {
      if (!rejectSpace) {
        return append(acc, x);
      }
      return acc;
    }
    if (x.length == undefined) { // Just an object, not a string or array.
      return append(acc, x);
    }
    if (rejectSpace &&
        ((x.length == 0) ||
         (typeof(x) == "string" &&
          x.match(/^\s*$/)))) {
      return acc;
    }
    if (typeof(x) == "string") {
      return append(acc, x);
    }
    for (var i = 0; i < x.length; i++) {
      flatten(x[i], rejectSpace, acc);
    }
    return acc;
}

function flatstr(x, rejectSpace, joinChar) {
    return flatten(x, rejectSpace, []).join(joinChar || '');
}

function filter(arr, x) {
    var acc = [];
    for (var i = 0; i < arr.length; i++) {
      if (arr[i] != x) {
        acc[length] = arr[i];
      }
    }
    return acc;
}

function nonempty(x) {             // Ex: nonempty("") == null;
    if (x == null || x.length > 0) { // Ex: nonempty(null) == null;
       return x;
    }
    return null;
}

function put_if_not_null(m, key, val) {
    if (val) {
      m[key] = val;
    }
    return m;
  }
  function merge(src, dst) {
    for (var k in src) {
      dst[k] = src[k];
    }
    return dst;
}

