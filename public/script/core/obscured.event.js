Obscured.Event = (function ($) {
    function Event() {
        window.observers = {};
    }
    Event.prototype.observe = function observeObject(event, namespace, obj) {
        Obscured.Debug.Logger({ contract: 'Event', message: 'Adding new observer for ' + namespace + "." + event, level: Level.INFO });
        
        if (!window.observers[namespace])
            window.observers[namespace] = [];

        if (!window.observers[namespace][event])
            window.observers[namespace][event] = [];
        
        window.observers[namespace][event].push(obj);
    };

    Event.prototype.notify = function notifyObservers(event, namespace, data) {
        Obscured.Debug.Logger({ contract: 'Event', message: 'Event triggerd on observer for ' + namespace + "." + event, level: Level.INFO });
        if (window.observers[namespace][event]) {
            for (var i = 0, len = window.observers[namespace][event].length; i < len; i++) {
                var listener = window.observers[namespace][event][i];
                listener['on' + event].apply(listener, [data]);
            }
        } else {
            Obscured.Debug.Logger({ contract: 'Event', message: 'Could not find observer for ' + namespace + "." + event, level: Level.DEBUG });
        }
    };
    return Event;
}());