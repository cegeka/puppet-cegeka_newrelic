# Class: newrelic::server_monitoring
#
# This class manages the installation of newrelic::server_monitoring
#
# Parameters:
#
# [*newrelic_license_key*] 40-character hexadecimal string provided by New Relic. This is required in order for the server monitor to start (no default).
# - Required: yes
# - Content: String
#
# [*newrelic_loglevel*] The level of detail you want in the log file (default: 'info').
# - Required: no
# - Content: 'error' | 'warning' | 'info' | 'verbose' | 'debug' | 'verbosedebug'
#
# [*newrelic_logfile*] The name of the file where the server monitor will store it's log messages (default: '/var/log/newrelic/nrsysmond.log').
# - Required: no
# - Content: String
#
# Sample Usage:
#
# class { 'newrelic::server_monitoring':
#   newrelic_license_key => '<insert license key here>',
# }
#
class newrelic::server_monitoring(
  $newrelic_license_key=undef,
  $newrelic_sysmond_version='present',
  $newrelic_loglevel='info',
  $newrelic_logfile='/var/log/newrelic/nrsysmond.log'
) {

  if $newrelic_license_key == undef {
    fail('The license key associated with your New Relic account must be provided')
  }

  if ! ($newrelic_loglevel in ['error', 'warning', 'info','verbose','debug', 'verbosedebug']) {
    fail("${newrelic_loglevel} is not one of valid predefined values for loglevels")
  }

  case $newrelic_sysmond_version {
    '2.3.0.132-1': { $newrelic_sysmond_config_template = "${module_name}/server/nrsysmond.cfg.2.3.0.erb" }
    default:       { $newrelic_sysmond_config_template = "${module_name}/server/nrsysmond.cfg.erb" }
  }

  package { 'newrelic-sysmond':
    ensure  => $newrelic_sysmond_version,
  }

  file { '/etc/newrelic/nrsysmond.cfg':
    ensure  => file,
    owner   => root,
    group   => newrelic,
    mode    => '0640',
    content => template($newrelic_sysmond_config_template),
    notify  => Service['newrelic-sysmond'],
    require => Package['newrelic-sysmond'],
  }

  service { 'newrelic-sysmond':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => Package['newrelic-sysmond'],
  }

}
