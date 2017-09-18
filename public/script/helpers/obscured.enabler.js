/**
 * @namespace Obscured.Helpers.Enabler Namespace
 * @this {Obscured.Helpers}
 */
Obscured.Helpers.Enabler = (function ($) {
    "use strict";
    return {
        Bind: function (options) {
            jQuery('[data-trigger="enabler"]').off('click');
            jQuery('[data-trigger="enabler"]').on('click', function(e) {
                e.preventDefault();

                // Set option values
                options.loaderId = (typeof options.loaderId === 'undefined' ? guid() : options.loaderId);

                var url = jQuery(this).attr('data-url'),
                    enabled = jQuery(this).attr('data-enabled');

                Obscured.Loader.Start({ id: options.loaderId, target: options.target, template: '#loader-inline', method: 'append' });
                Obscured.Ajax.Post({
                    url: url,
                    cache: false,
                    contentType: "application/x-www-form-urlencoded;charset=utf-8",
                    data: {enabled: enabled},
                    dataType: 'json',
                    success: function (response) {
                        if(!response.success) {
                            var linkModel = {
                                class: 'alert-danger',
                                title: (typeof options.title === 'undefined' ? response.type : options.title),
                                message: (typeof options.message === 'undefined' ? response.message : options.message)
                            };
                            Obscured.Template.Render({ source: jQuery('#template-alert').html(), context: linkModel, parent: $('#alert-wrapper'), method: 'prepend' });
                        }
                    },
                    complete: function () {
                        Obscured.Loader.Stop({ id: options.loaderId });
                    },
                    error: function (jqxhr, errMessage, errThrown) {
                        Obscured.Loader.Stop({ id: options.loaderId });
                        if(typeof jqxhr.responseJSON !== 'undefined') {
                            Obscured.Error.Throw({ contract: 'ajax', error: jqxhr, level: Level.ERROR, statusCode: jqxhr.status, message: jqxhr.responseJSON.message, title: jqxhr.responseJSON.type });
                        }
                        else {
                            Obscured.Error.Throw({ contract: 'ajax', error: jqxhr, level: Level.ERROR, statusCode: Obscured.Ajax.TranslateStatusText(jqxhr.statusText) });
                        }
                        Obscured.Debug.Logger({ contract: 'ajax', message: errThrown, level: Level.ERROR });
                    }
                });
            });
        }
    };
})(jQuery);