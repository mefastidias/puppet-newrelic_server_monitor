# Class: newrelic_server_monitor
#
#   This module adds the New Relic Server Monitor to the target node.
#
# Parameters:
#
#  [*license_key*] - The license key supplied by New Relic on the instructions
#                    page for setting up a new Server Monitor instance.
#
#  [*use_latest*] - Whether to update the required packages automatically.
#
# Sample Usage:
#
#   class { 'newrelic_server_monitor':
#     license_key => 'YOUR_LICENSE_KEY',
#     use_latest  => true
#   }
#
class newrelic_server_monitor (
  $license_key  = undef,
  $use_latest   = false,
) {
  if $license_key == undef {
    fail('The license_key parameter must be defined.')
  }

  if $use_latest == true {
    $package_ensure = 'latest'
  } elsif $use_latest == false {
    $package_ensure = 'present'
  } else {
    fail('The use_latest parameter must be true or false.')
  }

  case $::osfamily {
    'Debian': {
      $add_repo_cmd     = '/usr/bin/wget -O /etc/apt/sources.list.d/newrelic.list http://download.newrelic.com/debian/newrelic.list'
      $add_repo_key_cmd = '/usr/bin/apt-key adv --keyserver hkp://pool.sks-keyservers.net --recv-keys 548C16BF'
      $update_repos_cmd = '/usr/bin/apt-get update -y -qq'

      exec { 'add_newrelic_repo':
        command => $add_repo_cmd,
        notify  => Exec['update_repos'],
        unless  => '/usr/bin/test -f /etc/apt/sources.list.d/newrelic.list'
      }

      exec { 'add_newrelic_repo_key':
        command => $add_repo_key_cmd,
        require => Exec['add_newrelic_repo'],
        notify  => Exec['update_repos'],
        unless  => '/usr/bin/test `/usr/bin/apt-key list | /bin/grep 548C16BF -c` -eq 1'
      }

      exec { 'update_repos':
        command     => $update_repos_cmd,
        require     => Exec['add_newrelic_repo_key'],
        before      => Package['newrelic-sysmond'],
        refreshonly => true,
      }
    }

    'RedHat': {
      package { 'newrelic-repo':
        ensure    => $package_ensure,
        provider  => 'rpm',
        source    => 'http://download.newrelic.com/pub/newrelic/el5/i386/newrelic-repo-5-3.noarch.rpm',
        before    => Package['newrelic-sysmond']
      }
    }

    default: {
      fail("The newrelic_server_monitor module does not support ${::osfamily}.")
    }
  }

  package { 'newrelic-sysmond':
    ensure  => $package_ensure
  }

  file { '/etc/newrelic/nrsysmond.cfg':
    ensure  => 'present',
    mode    => '0640',
    owner   => 'root',
    group   => 'newrelic',
    notify  => Service['newrelic-sysmond'],
    content => template('newrelic_server_monitor/nrsysmond.cfg.erb'),
    require => Package['newrelic-sysmond'],
  }

  service { 'newrelic-sysmond':
    ensure  => running,
    enable  => true,
    require => [ Package['newrelic-sysmond'], File['/etc/newrelic/nrsysmond.cfg'] ]
  }
}
