// Debug variable
var debug = false;

/**
 * @namespace Obscured.Debug Namespace
 * @this {Obscured.Debug}
 */
Obscured.Debug = (function () {
    "use strict";
    return {
        /**
         * @public
         * @description Logging function to send logs to the conosle.
         * @param {object} options
         */
        Logger: function (options) {
            function capitalise(string) {
                return string.charAt(0).toUpperCase() + string.slice(1);
            }
            
            if (debug) {
                if (options.level) {
                    if (options.level === Level.INFO) {
                        console.info('%c[' + options.level.name + '] ' + capitalise(options.contract) + ': ' + options.message, 'color: ' + options.level.color + ' ;');
                    }
                    else if (options.level === Level.WARN) {
                        console.warn('%c[' + options.level.name + '] ' + capitalise(options.contract) + ': ' + options.message, 'color: ' + options.level.color + ' ;');
                    }
                    else if (options.level === Level.ERROR || options.level === Level.FATAL) {
                        console.error('%c[' + options.level.name + '] ' + capitalise(options.contract) + ': ' + options.message, 'color: ' + options.level.color + ' ;');
                    }
                    else {
                        console.log('%c[' + options.level.name + '] ' + capitalise(options.contract) + ': ' + options.message, 'color: ' + options.level.color + ' ;');
                    }
                }
                else {
                    console.log('%c[' + Level.INFO.name + '] ' + capitalise(options.contract) + ': ' + options.message, 'color: ' + Level.INFO.color + ';');
                }

                if (options.stack) {
                    console.log(options.stack);
                }
            }
        }
    };
}());


// Enable logging with parameter to make it more flexible
(function () {
    var i,
        intPort = window.location.port,
        strHref = window.location.href,
        strParamName = 'debug',
        strReturn = '';

    if (strHref.indexOf('?') > -1) {
        var strQueryString = strHref.substr(strHref.indexOf('?')).toLowerCase(),
            aQueryString = strQueryString.split('&');

        for (i = 0; i < aQueryString.length; i++) {
            if (aQueryString[i].indexOf(strParamName.toLowerCase() + '=') > -1) {
                var strParam = aQueryString[i].split('=');
                strReturn = strParam[1];
                break;
            }
        }

        if (strReturn !== '') {
            debug = true;
            Obscured.Debug.Logger({ contract: 'environment', message: 'Forcing debug to true' });
        }
    }

    if (intPort !== "" && intPort !== 80) {
        debug = true;
        Obscured.Debug.Logger({ contract: 'environment', message: 'Develop environment, settings debug to true (port: ' + intPort + ')' });
    }
}());