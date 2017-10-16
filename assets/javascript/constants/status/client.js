function BadRequest(message) {
    this.name = "Bad Request";
    this.code = 400;
    this.message = (message || "The server cannot or will not process the request due to an apparent client error.");
}
BadRequest.prototype = Error.prototype;

function Unauthorized(message) {
    this.name = "Unauthorized";
    this.code = 401;
    this.message = (message || "The request was valid, but the server is refusing action. The user might not have the necessary permissions for a resource, or may need an account of some sort.");
}
Unauthorized.prototype = Error.prototype;

function PaymentRequired(message) {
    this.name = "Payment Required";
    this.code = 402;
    this.message = (message || "");
}
PaymentRequired.prototype = Error.prototype;

function Forbidden(message) {
    this.name = "Forbidden";
    this.code = 403;
    this.message = (message || "The request was valid, but the server is refusing action. The user might not have the necessary permissions for a resource, or may need an account of some sort.");
}
Forbidden.prototype = Error.prototype;

function NotFound(message) {
    this.name = "Not Found";
    this.code = 404;
    this.message = (message || "The requested resource could not be found but may be available in the future. Subsequent requests by the client are permissible.");
}
NotFound.prototype = Error.prototype;

function MethodNotAllowed(message) {
    this.name = "Method Not Allowed";
    this.code = 405;
    this.message = (message || "A request method is not supported for the requested resource; for example, a GET request on a form that requires data to be presented via POST, or a PUT request on a read-only resource.");
}
MethodNotAllowed.prototype = Error.prototype;

function NotAcceptable(message) {
    this.name = "Not Acceptable";
    this.code = 406;
    this.message = (message || "The requested resource is capable of generating only content not acceptable according to the Accept headers sent in the request.");
}
NotAcceptable.prototype = Error.prototype;

function ProxyAuthenticationRequired(message) {
    this.name = "Proxy Authentication Required";
    this.code = 407;
    this.message = (message || "The client must first authenticate itself with the proxy.");
}
ProxyAuthenticationRequired.prototype = Error.prototype;

function RequestTimeout(message) {
    this.name = "Request Timeout";
    this.code = 408;
    this.message = (message || "The server timed out waiting for the request.");
}
RequestTimeout.prototype = Error.prototype;

function Conflict(message) {
    this.name = "Conflict";
    this.code = 408;
    this.message = (message || "Indicates that the request could not be processed because of conflict in the request, such as an edit conflict between multiple simultaneous updates.");
}
Conflict.prototype = Error.prototype;