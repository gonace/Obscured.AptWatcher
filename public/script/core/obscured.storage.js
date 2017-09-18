/**
 * @namespace Obscured.Storage Namespace
 * @this {Obscured.Storage}
 * @description options { contract: "String", id: "String", entry: "dyanmic" }
 * @key - Is a key so that the localStorage is ordered and not a total mess
 * @entry - Is the value which is stored in the localStorage, this could be of any data type.
 */
Obscured.Storage = (function () {
    "use strict";
    var storage;

    return {
        /**
         * @public
         * @description Get
         * @param {object} options
         * @constructor
         */
        Get: function (options) {
            if (!Obscured.Storage.Supported()) {
                return;
            }

            // Parse the entry if the skip option is not provided
            if (!options.parse) {
                return JSON.parse(window.localStorage.getItem(options.key));
            }

            return window.localStorage.getItem(options.key);
        },
        /**
         * @public
         * @description Set
         * @param {object} options
         * @constructor
         */
        Set: function (options) {
            if (!Obscured.Storage.Supported()) {
                return;
            }

            // Stringify  the entry if the skip option is not provided
            if (!options.stringify) {
                options.entry = JSON.stringify(options.entry);
            }

            window.localStorage.setItem(options.key, options.entry);
        },
        /**
         * @public
         * @description Delete
         * @param {object} options
         * @constructor
         */
        Delete: function (options) {
            if (!Obscured.Storage.Supported()) {
                return;
            }

            window.localStorage.removeItem(options.key);
        },
        /**
         * @public
         * @description Supported, check if localStorage is supported
         * @constructor
         */
        Supported: function () {
            if (storage === undefined || storage === "") {
                storage = this.isSupported();
            }

            return storage;
        },
        isSupported: function () {
            try {
                localStorage.setItem('test', 'test');
                localStorage.removeItem('test');
                return true;
            }
            catch (e) {
                return false;
            }
        }
    };
})();