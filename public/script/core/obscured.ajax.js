/**
 * @namespace Obscured.Ajax Namespace
 * @this {Obscured.Ajax}
 */
Obscured.Ajax = function () {
    "use strict";
    /**
     * @public
     * @description Send a query to backend.
     * @param {object} options.
     */
    var doCall = function (options) {
        // Check if options is undefined
        if (typeof options === 'undefined' || options === null) {
            throw new ArgumentException('Obscured.Ajax.Query requires base options, please check your arguments');
        }

        // Set option values
        options.async = (typeof options.async === 'undefined' ? true : options.async);
        options.cache = (typeof options.cache === 'undefined' ? true : options.cache);
        options.complete = (typeof options.complete === 'undefined' ? undefined : options.complete);
        options.success = (typeof options.success === 'undefined' ? true : options.success);
        options.callbackOptions = (typeof options.callbackOptions === 'undefined' ? undefined : options.callbackOptions);
        options.contentType = (typeof options.contentType === 'undefined' ? 'application/json;charset=utf-8' : options.contentType);
        options.crossDomain = (typeof options.crossDomain === 'undefined' ? false : options.crossDomain);
        options.data = (typeof options.data === 'undefined' ? false : options.data);
        options.dataType = (typeof options.dataType === 'undefined' ? undefined : options.dataType);
        options.error = (typeof options.error === 'undefined' ? undefined : options.error);
        options.jsonp = (typeof options.jsonp === 'undefined' ? false : options.jsonp);
        options.timeout = (typeof options.timeout === 'undefined' ? 5000 : options.timeout);
        options.type = (typeof options.type === 'undefined' ? 'GET' : options.type);
        options.query = (typeof options.query === 'undefined' ? undefined : options.query);
        options.url = (typeof options.url === 'undefined' ? undefined : options.url);

        if (typeof options.url === 'undefined') {
            throw new Error('Obscured.Ajax requires an url, please check your arguments');
        }

        if (typeof options.query !== 'undefined' && options.query !== null) {
            options.url += '?' + options.query;
        }

        var apiOptions = {
            async: options.async,
            cache: options.cache,
            crossDomain: options.crossDomain,
            timeout: options.timeout,
            type: options.type,
            url: options.url,
            complete: function (jqxhr) {
                if (!options.jsonp && options.complete) {
                    options.complete(jqxhr);
                }
            },
            success: function (data) {
                if (!options.jsonp && typeof data !== 'undefined' && options.success) {
                    if (options.callbackOptions) {
                        options.success(data, options.callbackOptions);
                    }
                    else {
                        options.success(data);
                    }
                }
            },
            error: function (jqxhr, errMessage, errThrown) {
                if (options.error) {
                    options.error(jqxhr, errMessage, errThrown);
                } else {
                    Obscured.Error.Throw({ contract: 'ajax', error: jqxhr, level: Level.FATAL, parameters: apiOptions, statusCode: Obscured.Ajax.TranslateStatusText(jqxhr.statusText) });
                    Obscured.Debug.Logger({ contract: 'ajax', message: errThrown, level: Level.FATAL });
                }
            }
        };

        // JSONP Options
        if (options.jsonp) {
            apiOptions.crossDomain = true;
            apiOptions.jsonpCallback = options.callback;
        }

        if (typeof options.contentType !== 'undefined' && options.contentType !== null) {
            apiOptions.contentType = options.contentType;
        }

        if (typeof options.data !== 'undefined' && options.data !== null) {
            apiOptions.data = options.data;
        }

        if (typeof options.dataType !== 'undefined' && options.dataType !== null) {
            apiOptions.dataType = options.dataType;
        }
        jQuery.ajax(apiOptions);
    };

    return {
        /**
         * @public
         * @description POST
         * @param {object} options
         * @constructor
         */
        Post: function (options) {
            // Check if options is undefined
            if (typeof options === 'undefined' || options === null) {
                throw new ArgumentException('Obscured.Ajax.Post requires base options, please check your arguments');
            }
            options.type = 'POST';

            doCall(options);
        },
        /**
         * @public
         * @description GET
         * @param {object} options
         * @constructor
         */
        Get: function (options) {
            // Check if options is undefined
            if (typeof options === 'undefined' || options === null) {
                throw new ArgumentException('Obscured.Ajax.Get requires base options, please check your arguments');
            }
            options.type = 'GET';

            doCall(options);
        },
        /**
         * @public
         * @description PUT, Not supported by all browsers.
         * @param {object} options
         * @constructor
         */
        Put: function (options) {
            // Check if options is undefined
            if (typeof options === 'undefined' || options === null) {
                throw new ArgumentException('Obscured.Ajax.Put requires base options, please check your arguments');
            }
            options.type = 'PUT';

            doCall(options);
        },
        /**
         * @public
         * @description DELETE, Not supported by all browsers.
         * @param {object} options
         * @constructor
         */
        Delete: function (options) {
            // Check if options is undefined
            if (typeof options === 'undefined' || options === null) {
                throw new ArgumentException('Obscured.Ajax.Delete requires base options, please check your arguments');
            }
            options.type = 'DELETE';

            doCall(options);
        },
        /**
         * @public
         * @description Convert Query to a string.
         * @param {object} query A query object.
         * @returns {string} A query string based on the query object received.
         */
        QueryToQueryString: function (query) {
            var attr, queryString = [];
            for (attr in query) {
                if (query.hasOwnProperty(attr)) {
                    if (typeof query[attr] !== 'undefined' && query[attr] !== null && query[attr] !== 'null') {
                        queryString.push(attr + '=' + query[attr]);
                    }
                }
            }
            return queryString.join("&");
        },
        /**
         * @public
         * @description Evaluate a response from a backend query.
         * @param {object} data
         * @returns {boolean}
         */
        Eval: function (data) {
            return typeof data !== 'undefined';
        },
        /**
         * @public
         * @description Returns the correct HTTP Status Code by jQuery ajax statusText.
         * @param {string} statusText
         * @return {number}
         */
        TranslateStatusText: function (statusText) {
            switch(statusText) {
                case "success":
                    return 200;
                case "notmodified":
                    return 304;
                case "nocontent":
                    return 204;
                case "error":
                    return 500;
                case "timeout":
                    return 408;
                case "abort":
                    return 500;
                case "parsererror":
                    return 500;
                default:
                    return 500;
            }
        }
    };
}();