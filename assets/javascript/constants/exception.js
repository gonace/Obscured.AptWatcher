function NotImplementedException(message) {
    this.name = "NotImplementedException";
    this.message = (message || "");
}
NotImplementedException.prototype = Error.prototype;


function ArgumentException(message) {
    this.name = "ArgumentException";
    this.message = (message || "");
}
ArgumentException.prototype = Error.prototype;


function NotSupportedException(message) {
    this.name = "NotSupportedException";
    this.message = (message || "");
}
NotSupportedException.prototype = Error.prototype;


function NullReferenceException(message) {
    this.name = "NullReferenceException";
    this.message = (message || "");
}
NullReferenceException.prototype = Error.prototype;


function VerificationException(message) {
    this.name = "VerificationException";
    this.message = (message || "");
}
VerificationException.prototype = Error.prototype;


function SecurityException(message) {
    this.name = "SecurityException";
    this.message = (message || "");
}
SecurityException.prototype = Error.prototype;


function TimeoutException(message) {
    this.name = "TimeoutException";
    this.message = (message || "");
}
TimeoutException.prototype = Error.prototype;


function AccessViolationException(message) {
    this.name = "AccessViolationException";
    this.message = (message || "");
}
AccessViolationException.prototype = Error.prototype;


function SerializationException(message) {
    this.name = "SerializationException";
    this.message = (message || "");
}
SerializationException.prototype = Error.prototype;


function ServerException(message) {
    this.name = "ServerException";
    this.message = (message || "");
}
ServerException.prototype = Error.prototype;


function PolicyException(message) {
    this.name = "PolicyException";
    this.message = (message || "");
}
PolicyException.prototype = Error.prototype;


function TimeoutException(message) {
    this.name = "TimeoutException";
    this.message = (message || "");
}
TimeoutException.prototype = Error.prototype;


function FormatException(message) {
    this.name = "FormatException";
    this.message = (message || "");
}
FormatException.prototype = Error.prototype;