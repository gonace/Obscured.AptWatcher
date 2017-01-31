/**
 * @namespace Obscured.Error Namespace
 * @this {Obscured.Error}
 * @extends Obscured
 */
Obscured.Error = function ($) {
    "use strict";
    return {
        /**
         * @public
         * @description Throw an error.
         * @param {object} err containing error to be sent to raygun.
         */
        Throw: function (options) {
            if (typeof options.raygun == 'undefined' || options.raygun == null) {
                options.raygun = false;
            }

            function capitalise(string) {
                return string.charAt(0).toUpperCase() + string.slice(1);
            }

            // Added status so to beeing correctly shown in RayGun (This will be the error heading).
            if (options.contract) {
                options.Status = 'Error thrown in Obscured.' + capitalise(options.contract) + ' (Further details in UserCustomData)';
            }

            // If raygun is enabled send data to raygun
            if (options.raygun) {
                // Define payload to send to raygun
                var model = {
                    'OccurredOn': new Date(),
                    'Message': options.status || 'Script error',
                    'Status': options.status || 'Script error',
                    'Error': options.error || null,
                    'Level': options.level || undefined,
                    'Request': {
                        'Parameters': options.parameters || null,
                    }
                };

                // Send payload to raygun
                Raygun.send(new Error(payload.Message), model);
            }

            // Render a friendly error to the client.
            if (options.level === Level.FATAL) {
                window.location.href = "/error";
            }
            else if (options.level === Level.ERROR) {
                Obscured.Error.Render(options);
            }
        },
        /**
         * @public
         * @description Renders the error to the browser.
         * @param {object} model A Obscured.Error.Models.Error model that will be rendered.
         */
        Render: function (options) {
            options.title = (typeof options.title === 'undefined' ? undefined : options.title);
            options.message = (typeof options.message === 'undefined' ? undefined : options.message);
            options.button = (typeof options.button === 'undefined' ? undefined : options.button);
            options.parent = (typeof options.parent === 'undefined' ? $('body') : $(options.parent));
            options.template = (typeof options.template === 'undefined' ? $('#error-clientside').html() : $(options.template).html());

            var httpStatus = Obscured.Error.GetStatus(options.statusCode);
            if (options.title == undefined && httpStatus && httpStatus.Status)
                options.title = httpStatus.Status;
            if (options.message == undefined && httpStatus && httpStatus.Message)
                options.message = httpStatus.Message;

            if (options.title == undefined)
                options.title = 'An extraterrestrial error has occurred.';
            if (options.message == undefined)
                options.message = 'Something that we can not control happened. It may work the next time';
            if (options.button == undefined)
                options.button = 'Ok, reload';


            var contextModel = {
                title: options.title,
                message: options.message,
                button: options.button
            };
            Obscured.Template.Render({ source: options.template, context: contextModel, parent: options.parent});
        },
        /**
         * @public
         * @description GetStatus.
         * @param {int} status A HTTP Status Code that describes the error thrown.
         * @returns {object} Returns a Obscured.Error.Models.Status model.
         */
        GetStatus: function (statusCode) {
            var response = new Obscured.Error.Models.Status(statusCode, null, null);

            if (statusCode === 0) {
                response.Status = "Request Timeout";
                response.Message = "The server timed out waiting for the request.";
                return response;
            }
            else if (statusCode === 204) {
                response.Status = "No Content";
                response.Message = "The server has fulfilled the request but has no data to return.";
                return response;
            }
            else if (statusCode === 400) {
                response.Status = "Bad Request";
                response.Message = "The request could not be understood by the server due to malformed syntax.";
                return response;
            }
            else if (statusCode === 401) {
                response.Status = "Unauthorized";
                response.Message = "The request requires user authentication and/or failed.";
                return response;
            }
            else if (statusCode === 403) {
                response.Status = "Forbidden";
                response.Message = "The server understood the request, but is refusing to fulfill it.";
                return response;
            }
            else if (statusCode === 404) {
                response.Status = "Not Found";
                response.Message = "The server didn't found anything matching the Request-URI.";
                return response;
            }
            else if (statusCode === 405) {
                response.Status = "Method Not Allowed";
                response.Message = "The method specified in the Request-Line is not allowed for the resource identified by the Request-URI.";
                return response;
            }
            else if (statusCode === 408) {
                response.Status = "Request Timeout";
                response.Message = "The client did not produce a request within the time that the server was prepared to wait.";
                return response;
            }
            else if (statusCode === 500) {
                response.Status = "";
                response.Message = "";
                return response;
            }

            response.StatusCode = null;
            response.Status = "Unknown Error";
            response.Message = "An unknown error occured while processing the data.";
            return response;
        }
    };
}(jQuery);

/**
 * @namespace Obscured.Error.Models Namespace
 * @this {Obscured.Error.Models}
 */
Obscured.Error.Models = function () {
    "use strict";
    return {
        /**
         * @public
         * @description Error model.
         * @param {string} header A short header that describe the nature of the error.
         * @param {string} message A message that describes the error.
         * @param {object} status A object that are used for debuging the application.
         */
        Error: function (header, message, status) {
            this.Header = (typeof header === 'undefined' ? null : header);
            this.Message = (typeof message === 'undefined' ? null : message);
            this.Status = (typeof status === 'undefined' ? null : status);
        },
        /**
         * @public
         * @description Status model.
         * @param {int} statuscode A HTTP Status Code that describes the error thrown.
         * @param {string} status A HTTP Status Header that describes the error thrown.
         * @param {string} message A HTTP Status Message that describes the error thrown.
         */
        Status: function (statuscode, status, message, level) {
            this.StatusCode = (typeof statuscode === 'undefined' ? null : statuscode);
            this.Status = (typeof status === 'undefined' ? null : status);
            this.Message = (typeof message === 'undefined' ? null : message);
        }
    };
}();