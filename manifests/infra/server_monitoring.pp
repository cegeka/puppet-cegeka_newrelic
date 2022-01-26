# Class: cegeka_newrelic::infra::server_monitoring
#
# This class manages the installation of cegeka_newrelic::server_monitoring
#
# Parameters:
#
# [*newrelic_license_key*] 40-character hexadecimal string provided by New Relic. This is required in order for the server monitor to start (no default).
# - Required: yes
# - Content: String
#
# Sample Usage:
#
# class { 'cegeka_newrelic::server_monitoring':
#   newrelic_license_key => '<insert license key here>',
# }
#
class cegeka_newrelic::infra::server_monitoring(
  $ensure = present,
  $service_enable = true,
  $service_ensure = running,
  $newrelic_license_key = undef,
  $newrelic_config = '/etc/newrelic-infra.yml'
) {

  package { 'newrelic-infra':
    ensure => $ensure
  }

  service { 'newrelic-infra':
    ensure  => $service_ensure,
    enable  => $service_enable,
    require => [Package['newrelic-infra'],File[$newrelic_config]]
  }

  file { $newrelic_config :
    ensure  => $ensure,
    content => "license_key: ${newrelic_license_key}",
    notify  => Service['newrelic-infra']
  }

}
