# Class: newrelic::application_monitoring
#
# This class manages the installation of newrelic::application_monitoring
#
# Parameters:
#
# [*application_root_dir*] The New Relic agent installation directory (no default).
# - Required: yes
# - Content: String
#
# [*application_owner*] The owner of the New Relic agent installation directory (default: 'root').
# - Required: yes
# - Content: String
#
# [*application_group*] The group of the New Relic agent installation directory (default: 'root').
# - Required: yes
# - Content: String
#
# [*newrelic_license_key*] 40-character hexadecimal string provided by New Relic. This is required in order for the server monitor to start (no default).
# - Required: yes
# - Content: String
#
# [*newrelic_app_name*] Set the name of your application as you'd like it show up in New Relic (default: 'My Application').
# - Required: yes
# - Content: String
#
# [*newrelic_agent_loglevel*] The agent uses its own log file to keep its logging separate from that of your application (default: 'info').
# - Required: no
# - Content: 'off' | 'severe' | 'warning' | 'info' | 'fine' | 'finer' | 'finest'
#
# [*newrelic_use_ssl*] The agent communicates with New Relic via http by default.  If you want to communicate via https to increase security, 
#                      then turn on SSL by setting this value to true (default: false).
# - Required: no
# - Content: true | false
#
# Sample Usage:
#
# class { 'newrelic::application_monitoring':
# }
#
#
class newrelic::application_monitoring($application_root_dir=undef, $application_owner='root', $application_group='root', 
                                       $newrelic_license_key=undef, $newrelic_app_name='My Application', $newrelic_agent_loglevel='info', $newrelic_use_ssl=false) {

  if $application_root_dir == undef {
    fail("The root directory of the application server installation must be provided")
  }

  if $newrelic_license_key == undef {
    fail("The license key associated with your New Relic account must be provided")
  }

  if ! ($newrelic_agent_loglevel in ['off' , 'severe' , 'warning' , 'info' , 'fine' , 'finer' , 'finest']) {
    fail("${newrelic_agent_loglevel} is not one of valid predefined values for agent loglevels")
  }

  case $newrelic_use_ssl {
    true, false: { $newrelic_use_ssl_real = $newrelic_use_ssl }
    default: {
      fail("Newrelic::Application_monitoring[${newrelic_use_ssl}]: parameter newrelic_use_ssl must be a boolean")
    }
  }

  file { "${application_root_dir}/newrelic" :
    ensure => directory,
    owner  => $application_owner,
    group  => $application_group,
  }

  file { "${application_root_dir}/newrelic/logs" :
    ensure  => directory,
    owner   => $application_owner,
    group   => $application_group,
    require => File["${application_root_dir}/newrelic"],
  }

  file { "${application_root_dir}/newrelic/newrelic.jar" :
    ensure  => file,
    owner   => $application_owner,
    group   => $application_group,
    source  => "puppet:///modules/${module_name}/newrelic.jar",
    require => File["${application_root_dir}/newrelic"],
  }

  file { "${application_root_dir}/newrelic/newrelic.yml" :
    ensure  => file,
    owner   => $application_owner,
    group   => $application_group,
    content => template("${module_name}/application/newrelic.yml.erb"),
  }

}
