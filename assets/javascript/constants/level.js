/**
 * @description Error level, used for alerts and error notifications
 */
var Level = (function (level, name, color) {
    this.level = level;
    this.name = name;
    this.color = color;
});

Level.prototype = {
    toString: function () {
        return this.name;
    },
    equals: function (level) {
        return this.level == level.level;
    },
    isGreaterOrEqual: function (level) {
        return this.level >= level.level;
    }
};

// Declare debugging levels
Level.DEBUG = new Level(10000, "DEBUG", "#3c763d");
Level.INFO = new Level(20000, "INFO", "#31708f");
Level.WARN = new Level(30000, "WARN", "#8a6d3B");
Level.ERROR = new Level(40000, "ERROR", "#a94442");
Level.FATAL = new Level(50000, "FATAL", "#a94442");

window.Level = Level;