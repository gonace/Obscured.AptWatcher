[![Vulnerabilities](https://snyk.io/test/github/gonace/obscured.aptwatcher/badge.svg)](https://snyk.io/test/github/gonace/obscured.aptwatcher)
[![Build Status](https://travis-ci.org/gonace/Obscured.AptWatcher.svg?branch=master)](https://travis-ci.org/gonace/Obscured.AptWatcher)
[![Test Coverage](https://codeclimate.com/github/gonace/Obscured.AptWatcher/badges/coverage.svg)](https://codeclimate.com/github/gonace/Obscured.AptWatcher)
[![Code Climate](https://codeclimate.com/github/gonace/Obscured.AptWatcher/badges/gpa.svg)](https://codeclimate.com/github/gonace/Obscured.AptWatcher)

Obscured.AptWatcher is a simple web-app that helps you keep track of OS updates as well as keeping you up to date with actions to keep your servers updated and secure.

## How it works


#### Structure
One line is interpreted as one service
```
{
  "name": "service_name",
  "version_installed": "1.0.0",
  "version_available": "1.0.1"
}
```
##### Example Input
```
{"name":"service_a","version_installed":"1.0.0","version_available":"1.0.1"}
{"name":"service_b","version_installed":"1.0.0","version_available":"1.0.1"}
{"name":"service_c","version_installed":"1.0.0","version_available":"1.0.1"}
```



If any packages are in that payload that were not previously sent, a message is sent via a Slack incoming webhook with that list of new
packages.

## Installation
The easiest way to get going is deploying to Heroku:

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)

Otherwise, you can bundle, create your database, migrate, and run:

```
$ bundle
```

## Configuration

## License
AptWatcher is copyright © 2019 Obscured It is free software, and may be redistributed under the terms specified in the [LICENSE](/LICENSE) file.

## About AptWatcher
AptWatcher is maintained by the friendly crew at [Obscured](https://www.obscured.se/), an exception, performance, and uptime monitoring service for developers.

## Print Screens
![Home](http://i.imgur.com/wtBiaGr.jpg)

![Statistics](http://i.imgur.com/yLcp4mK.jpg)
