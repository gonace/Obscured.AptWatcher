/**
 * @namespace Obscured.Loader Namespace
 * @this {Obscured.Loader}
 */
Obscured.Loader = (function ($) {
    "use strict";
    return {
        /**
         * @public
         * @description Show the ajax loader
         * @param options Optional text to use by the loader
         */
        Start: function(options) {
            // Check if options is undefined
            if (typeof options === 'undefined' || options === null) {
                throw new ArgumentException('Obscured.Loader.Start requires base options, please check your arguments');
            }

            options.id = (typeof options.id === 'undefined' ? guid() : options.id);
            options.target = (typeof options.target === 'undefined' ? $('body') : $(options.target));
            options.text = (typeof options.text === 'undefined' ? '' : options.text);
            options.template = (typeof options.template === 'undefined' ? undefined : $(options.template));

            if (typeof options.template === 'undefined' || options.template === null) {
                throw new ArgumentException('Obscured.Loader.Start requires template option, please check your arguments');
            }

            var loaderModel = {
                id: options.id,
                text: options.text
            };
            Obscured.Template.Render({ source: options.template.html(), context: loaderModel, parent: options.target, method: 'append' })

            return options.id
        },
        /**
         * @public
         * @description Hide Loader element
         */
        Stop: function(options) {
            // Check if options is undefined
            if (typeof options === 'undefined' || options === null) {
                throw new ArgumentException('Obscured.Loader.Stop requires base options, please check your arguments');
            }

            options.id = (typeof options.id === 'undefined' ? '#loader-app' : '#'+options.id);

            $(options.id).remove();
        }
    };
})(jQuery);