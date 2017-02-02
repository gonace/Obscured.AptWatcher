/**
 * @namespace Obscured.Password Namespace
 * @this {Obscured.Password}
 */
Obscured.Password = function ($) {
    "use strict";
    return {
        /**
         * @public
         * @description Attach
         * @param {object} options
         * @constructor
         */
        Attach: function (options) {
            // Check if options is undefined
            if (typeof options == 'undefined' || options == null) {
                throw new ArgumentException('Obscured.Password requires base options, please check your arguments');
            }

            // Set option values
            options.element = (typeof options.element === 'undefined' ? undefined : $(options.element));
            if (typeof options.element == 'undefined') {
                throw new Error('Obscured.Password requires an element, please check your arguments');
            }
            options.username = (typeof options.username === 'undefined' ? undefined : options.username);
            if (typeof options.username == 'undefined') {
                throw new Error('Obscured.Password requires a username, please check your arguments');
            }
            options.template = (typeof options.template === 'undefined' ? undefined : jQuery(options.template).html());
            if (typeof options.username == 'undefined') {
                throw new Error('Obscured.Password requires a template, please check your arguments');
            }
            options.wrapper = (typeof options.wrapper === 'undefined' ? jQuery(options.element).parent() : jQuery(options.wrapper));


            $(options.element).on('keypress', function(e) {
                if (e.target.value.length > 4) {
                    var _class,
                        strength = PasswordStrength.test($(options.username).val(), e.target.value);

                    switch(strength.status) {
                        case 'weak':
                            _class = 'bg-danger';
                            break;
                        case 'good':
                            _class = 'bg-warning';
                            break;
                        case 'strong':
                            _class = 'bg-success';
                            break;
                    }

                    var contextModel = {
                        progress: strength.score,
                        theme: _class
                    };
                    Obscured.Template.Render({source: options.template, context: contextModel, parent: options.wrapper, method: 'insert'});
                }
            })
        }
    };
}(jQuery);