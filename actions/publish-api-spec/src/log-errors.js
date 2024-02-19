let flattenObject = function (ob) {
    var toReturn = {};

    for (var i in ob) {
        if (!ob.hasOwnProperty(i)) continue;

        if (typeof ob[i] == 'object') {
            var flatObject = flattenObject(ob[i]);
            for (var x in flatObject) {
                if (!flatObject.hasOwnProperty(x)) continue;

                toReturn[i + '.' + x] = flatObject[x];
            }
        } else {
            toReturn[i] = ob[i];
        }
    }
    return toReturn;
};

let logErrorMessages = function (err) {
    const flattened = flattenObject(err);
    for (const k in flattened) {
        if (k.includes('message')) {
            console.error(flattened[k]);
        }
    }
};

module.exports = logErrorMessages;
