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
    $package_ensure = latest
  } elsif $use_latest == false {
    $package_ensure = present
  } else {
    fail('The use_latest parameter must be true or false.')
  }

  case $::osfamily {
    'Debian': {
      $add_repo_cmd     = '/usr/bin/wget -O /etc/apt/sources.list.d/newrelic.list http://download.newrelic.com/debian/newrelic.list'
      $add_repo_key_cmd = '/usr/bin/apt-key adv --keyserver hkp://subkeys.pgp.net --recv-keys 548C16BF'
      $update_repos_cmd = '/usr/bin/apt-get update -y -qq'

      exec { 'add_newrelic_repo':
        command => $add_repo_cmd
      }

      exec { 'add_newrelic_repo_key':
        command => $add_repo_key_cmd,
        require => Exec[add_newrelic_repo]
      }

      exec { 'update_repos':
        command => $update_repos_cmd,
        require => Exec[add_newrelic_repo_key]
      }
    }

    'RedHat': {
      package { 'newrelic-repo':
        ensure    => $package_ensure,
        provider  => rpm,
        source    => 'http://download.newrelic.com/pub/newrelic/el5/i386/newrelic-repo-5-3.noarch.rpm'
      }

      exec { 'update_repos':
        command => '/bin/true',
        require => Package[newrelic-repo]
      }
    }

    default: {
      fail("The newrelic_server_monitor module does not support ${::osfamily}.")
    }
  }

  package { 'newrelic-sysmond':
    ensure  => $package_ensure,
    require => Exec[update_repos]
  }

  exec { 'nrsysmond-config':
    command => "/usr/sbin/nrsysmond-config --set license_key=${license_key}",
    require => Package[newrelic-sysmond],
    before  => Service[newrelic-sysmond]
  }

  service { 'newrelic-sysmond':
    ensure  => running,
    enable  => true,
    require => Package[newrelic-sysmond]
  }
}