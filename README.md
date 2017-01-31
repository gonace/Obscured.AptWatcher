AptWatcher is a simple Sinatra app that helps you keep track of packages that need updating on your servers.

## How it works

On each server you manage you set up a daily cron job that fetches the
list of packages that need to be updated and sends that list to
AptWatcher:

#### Structure
One line is interperted as one service
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
@daily apt-get --just-print upgrade 2>&1 | perl -ne 'if (/Inst\s([\w,\-,\d,\.,~,:,\+]+)\s\[([\w,\-,\d,\.,~,:,\+]+)\]\s\(([\w,\-,\d,\.,~,:,\+]+)\)? /i) {print "{\"name\":\"$1\",\"version_installed\":\"$2\",\"version_available\":\"$3\"},"}' | curl -u test:test --data-binary @- http://localhost:1338/api/collector/upgrades/$(hostname)
```
###### Bash
```
@daily apt-get upgrade -s | grep ^Inst | awk '{ print $2,$3; }' | tr -d '[]' | curl -u user:pass --data-binary @- https://your.aptwatcher.url/api/collector/upgrades/$(hostname) &> /dev/null
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

## About Obscured

AptWatcher is maintained by the friendly crew at [Obscured](https://www.obscured.se/), an exception, performance, and uptime monitoring service for developers.
