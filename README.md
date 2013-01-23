New Relic Server Monitoring
===========================

[![Build Status](https://travis-ci.org/plainprogrammer/puppet-newrelic_server_monitor.png)](https://travis-ci.org/plainprogrammer/puppet-newrelic_server_monitor)

A module to add New Relic Server Monitoring to your nodes.

Platforms
---------

This module has been tested against the following target operating systems:

* Ubuntu 12.04 (32 & 64)
* CentOS 6.0 (64)

This module has been tested against the following versions of Puppet:

* Puppet 3.0.2
* Puppet 2.7.20
* Puppet 2.6.17

Requirements
------------

This module has not external dependencies.

Installation
------------

    puppet module install plainprogrammer/newrelic_server_monitor

Usage
-----

    class { 'newrelic_server_monitor':
      license_key => 'YOUR_LICENSE_KEY',
      use_latest  => true
    }
