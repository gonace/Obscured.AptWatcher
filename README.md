<a href="https://snyk.io/test/github/gonace/obscured.aptwatcher"><img src="https://snyk.io/test/github/gonace/obscured.aptwatcher/badge.svg" alt="Known Vulnerabilities" data-canonical-src="https://snyk.io/test/github/gonace/obscured.aptwatcher" style="max-width:100%;"></a>
[![Build Status](https://travis-ci.org/gonace/Obscured.AptWatcher.svg?branch=master)](https://travis-ci.org/gonace/Obscured.AptWatcher)
[![Test Coverage](https://codeclimate.com/github/gonace/Obscured.AptWatcher/badges/coverage.svg)](https://codeclimate.com/github/gonace/Obscured.AptWatcher)
[![Code Climate](https://codeclimate.com/github/gonace/Obscured.AptWatcher/badges/gpa.svg)](https://codeclimate.com/github/gonace/Obscured.AptWatcher)

AptWatcher is a simple Sinatra app that helps you keep track of packages that need updating on your servers.

## How it works
On each server you manage you set up a daily cron job that fetches the list of packages that need to be updated and sends that list to
AptWatcher.

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

###### Perl
```
@daily apt-get --just-print upgrade 2>&1 | perl -ne 'if (/Inst\s([\w,\-,\d,\.,~,:,\+]+)\s\[([\w,\-,\d,\.,~,:,\+]+)\]\s\(([\w,\-,\d,\.,~,:,\+]+)\)? /i) {print "{\"name\":\"$1\",\"version_installed\":\"$2\",\"version_available\":\"$3\"} \n"}' | curl -u user:pass --data-binary @- http://hostname/api/collector/upgrades/$(hostname)
```

If any packages are in that payload that weren't previously sent, a
message is sent via a Slack incoming webhook with that list of new
packages.

## Installation
The easiest way to get going is deploying to Heroku:

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)

Otherwise, you can bundle, create your database, migrate, and run:

```
$ bundle
```

## Configuration
Check the [`.env` file](/.env) for the environment variables you can use to
configure the app.

## License
AptWatcher is copyright © 2017 Obscured It is free software, and may be redistributed under the terms specified in the [LICENSE](/LICENSE) file.

## About AptWatcher
AptWatcher is maintained by the friendly crew at [Obscured](https://www.obscured.se/), an exception, performance, and uptime monitoring service for developers.

## Print Screens
![Home](http://i.imgur.com/wtBiaGr.jpg)

![Statistics](http://i.imgur.com/yLcp4mK.jpg)

### Slack Icons
Icon:                                                           | Name
--------------------------------------------------------------- | ---------
![bug Ok](public/icons/bug-ok.png?raw=true ":bug-ok:")          | :bug-ok:
![bug info](public/icons/bug-info.png?raw=true ":bug-info:")    | :bug-info:
![bug Warn](public/icons/bug-warn.png?raw=true ":bug-warn:")    | :bug-warn:
![bug Error](public/icons/bug-error.png?raw=true ":bug-error:") | :bug-error:
