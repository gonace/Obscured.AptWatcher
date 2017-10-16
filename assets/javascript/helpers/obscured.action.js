/**
 * @namespace Obscured.Helpers.Enabler Namespace
 * @this {Obscured.Helpers}
 */
Obscured.Helpers.Action = function ($) {
    "use strict";
    return {
        Bind: function (options) {
            jQuery('[data-trigger="action"]').off('click');
            jQuery('[data-trigger="action"]').on('click', function(e) {
                e.preventDefault();

                var url = jQuery(this).attr('data-url'),
                    action = jQuery(this).attr('data-action'),
                    wrapper = (typeof jQuery(this).attr('data-wrapper') === 'undefined' ? jQuery('#action-wrapper') : jQuery(this).attr('data-wrapper'));

                jQuery('html, body').animate({
                    scrollTop: wrapper.offset().top - 25
                }, 250);


                var model = {
                    title: (typeof options.title === 'undefined' ? 'Oh snap! Homer questions if this is the right thing to do?!' : options.title),
                    message: (typeof options.message === 'undefined' ? "Homer pulls down his glasses and informs you that this action (<code>" + action + "</code>) will affect this end user, are you sure about it?" : options.message),
                    engage_button: (typeof options.engage_button === 'undefined' ? 'Take this action' : options.engage_link),
                    engage_link: (typeof options.engage_link === 'undefined' ? url + '/' + action: eval(options.engage_link)),
                    dismiss_button: (typeof options.dismiss_button === 'undefined' ? 'Doh, never mind' : options.dismiss_button)
                };

                if(typeof options.querystring !== 'undefined') {
                    model['engage_link'] = model['engage_link'].concat(options.querystring);
                }
                else {
                    if(typeof querystring !== 'undefined' && querystring !== '')
                        model['engage_link'] = model['engage_link'].concat(querystring);
                }

                Obscured.Template.Render({ source: jQuery('#alert-action').html(), context: model, parent: wrapper, method: 'replace' });
            });
        },
        Trigger: function (url) {
            var loaderId = guid();

            Obscured.Loader.Start({ id: loaderId, target: 'body', template: '#loader-app', method: 'append' });
            Obscured.Ajax.Post({
                url: url,
                cache: false,
                dataType: 'json',
                success: function (response) {
                    console.log(response);
                    if(response.success) {
                        var model = {
                            title: 'Well done!',
                            message: "We're glad to announce that he was successful in executing the action!",
                            dismiss_button: 'Close!'
                        };
                        Obscured.Template.Render({ source: jQuery('#alert-success').html(), context: model, parent: jQuery('#action-wrapper'), method: 'replace' });
                    }
                    else {
                        Obscured.Error.Throw({ contract: 'ajax', level: Level.ERROR, statusCode: 500, parent: '#action-wrapper', template: '#error-clientside-inline', message: response.message, title: response.type });
                    }
                },
                complete: function(jqxhr) {
                    Obscured.Loader.Stop({ id: loaderId });
                },
                error: function (jqxhr, errMessage, errThrown) {
                    Obscured.Loader.Stop({ id: loaderId });
                    Obscured.Error.Throw({ contract: 'ajax', error: jqxhr, level: Level.ERROR, statusCode: Obscured.Ajax.TranslateStatusText(jqxhr.statusText) });
                    Obscured.Debug.Logger({ contract: 'ajax', message: errThrown, level: Level.ERROR });
                }
            });
        }
    };
}(jQuery);