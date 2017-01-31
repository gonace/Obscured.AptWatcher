/**
 * @namespace Obscured.Template Namespace
 * @this {Obscured.Template}
 */
Obscured.Template = function ($) {
    "use strict";
    return {
        /**
         * @public
         * @description Render a template with data.
         */
        Render: function (options) {
            var template = Handlebars.compile(options.source),
                html = template(options.context);

            // Set option values
            options.method = typeof options.method === "undefined" ? "append" : options.method;

            if (options.method === "append")
                options.parent.append(html);
            else if (options.method === "prepend")
                options.parent.prepend(html);
            else if (options.method === "insert" || options.method === "replace")
                options.parent.html(html);
            else
                options.parent.append(html);

            if (options.callback)
                options.callback();
        }
    };
}(jQuery);