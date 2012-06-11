# Class: newrelic::application_monitoring
#
# This class manages the installation of newrelic::application_monitoring
#
# Parameters:
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

  file { "${application_root_dir}/newrelic" :
    ensure => directory,
    owner  => "${application_owner}",
    group  => "${application_group}",
  }

  file { "${application_root_dir}/newrelic/logs" :
    ensure  => directory,
    owner   => "${application_owner}",
    group   => "${application_group}",
    require => File["${application_root_dir}/newrelic"],
  }

  file { "${application_root_dir}/newrelic/newrelic.jar" :
    ensure  => file,
    owner   => "${application_owner}",
    group   => "${application_group}",
    source  => "puppet:///modules/${module_name}/newrelic.jar",
    require => File["${application_root_dir}/newrelic"],
  }

  file { "${application_root_dir}/newrelic/newrelic.yml" :
    ensure  => file,
    owner   => "${application_owner}",
    group   => "${application_group}",
    content => template("${module_name}/application/newrelic.yml.erb"),
  }


# /opt/newrelic/ voor logs ? mss beter onder /opt/appserver/newrelic/logs ?
# /opt/appserver/newrelic/newrelic.jar
# /opt/appserver/newrelic/newrelic.yml


}
