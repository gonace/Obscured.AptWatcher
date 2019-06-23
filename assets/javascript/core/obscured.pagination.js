/**
 * @namespace Obscured.Pagination Namespace
 * @this {Obscured.Pagination}
 */
Obscured.Pagination = (function ($) {
    "use strict";
    return {
        /**
         * @public
         * @description Render a new page
         */
        Page: function(e, elm) {
            e.preventDefault();

            var button = $(elm),
                nav = button.parents('nav'),
                url = nav.data('url'),
                wrapper = $(nav.data('for')),
                page = button.data('page'),
                disabled = button.data('disabled'),
                loaderId = guid();

            if(!disabled) {
                Obscured.Loader.Start({ id: loaderId, target: 'body', template: '#loader-app' });
                Obscured.Ajax.Get({
                    url: url + "/" + page,
                    cache: false,
                    contentType: "application/x-www-form-urlencoded;charset=utf-8",
                    timeout: 35000,
                    success: function (response) {
                        $(wrapper).replaceWith(response);

                        var newWrapper = $(nav.data('for'));
                        $('html, body').animate({
                            scrollTop: newWrapper.offset().top
                        }, 500);
                    },
                    complete: function() {
                        Obscured.Loader.Stop({ id: loaderId });
                    },
                    error: function (jqxhr, errMessage, errThrown) {
                        Obscured.Loader.Stop({ id: loaderId });
                        var options = {};
                        if(typeof jqxhr.responseJSON !== 'undefined') {
                            options = { contract: 'ajax', error: jqxhr, level: Level.ERROR, statusCode: jqxhr.status, message: jqxhr.responseJSON.message, title: jqxhr.responseJSON.type };
                        }
                        else {
                            options = { contract: 'ajax', error: jqxhr, level: Level.ERROR, statusCode: Obscured.Ajax.TranslateStatusText(jqxhr.statusText) };
                        }
                        Obscured.Error.Throw(options);
                        Obscured.Debug.Logger({ contract: 'ajax', message: errThrown, level: Level.ERROR });
                    }
                });
            }
        }
    };
}(jQuery));