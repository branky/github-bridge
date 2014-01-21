github-bridge
===========

The bridge between public GitHub (github.com) and private GitHub (GitHub Enterprise, github.mycompany.com).

Features
--------

* Fork a repopsitory on github.com, clone it to local, then create it on GitHub Enterprise. All remote repositories are set properly.

Installation
------------

* Install

```
  $ gem install github_api parseconfig github-bridge
```

* Configure
You need a configuration file to store your credentials to access private and public githubs.

```
  $ mkdir ~/.github; chmod 700 ~/.github
  $ touch ~/.github/bridge.conf; chmod 600 ~/.github/bridge.conf
  $ vi ~/.github/bridge.conf
```

The configuration file looks like:

```
[github]
login = 'your username on github.com'
password = 'your password on github.com'

[enterprise]
host = 'hostname of your company's github enterprise, e.g. github.your.company.com'
name = 'your company name'
login = 'your username on github enterprise'
password = 'your password on github enterprise'

[local]
path = 'path to your local repositories, .e.g. ~/git/'
```

Usage
-----

```
    $ ghb -h
```

Contribution
------------
Bug reports and pull requests welcome!
