function InternalServerError(message) {
    this.name = "Internal Server Error";
    this.code = 500;
    this.message = (message || "A generic error message, given when an unexpected condition was encountered and no more specific message is suitable.");
}
InternalServerError.prototype = Error.prototype;

function NotImplemented(message) {
    this.name = "Not Implemented";
    this.code = 501;
    this.message = (message || "The server either does not recognize the request method, or it lacks the ability to fulfill the request.");
}
NotImplemented.prototype = Error.prototype;

function BadGateway(message) {
    this.name = "BadGateway";
    this.code = 502;
    this.message = (message || "The server was acting as a gateway or proxy and received an invalid response from the upstream server.");
}
BadGateway.prototype = Error.prototype;

function ServiceUnavailable(message) {
    this.name = "Service Unavailable";
    this.code = 503;
    this.message = (message || "The server is currently unavailable (because it is overloaded or down for maintenance).");
}
ServiceUnavailable.prototype = Error.prototype;

function GatewayTimeout(message) {
    this.name = "Gateway Timeout";
    this.code = 504;
    this.message = (message || "The server was acting as a gateway or proxy and did not receive a timely response from the upstream server.");
}
GatewayTimeout.prototype = Error.prototype;