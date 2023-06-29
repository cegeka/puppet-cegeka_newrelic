# Define: cegeka_newrelic::application_monitoring
#
# This defined type manages the installation of cegeka_newrelic::application_monitoring
#
# Parameters:
#
# [*newrelic_version*] The version of the New Relic agent (no default).
# - Required: yes
# - Content: String
#
# [*newrelic_app_root_dir*] The New Relic agent installation directory (no default).
# - Required: yes
# - Content: String
#
# [*newrelic_app_owner*] The owner of the New Relic agent installation directory (default: 'root').
# - Required: yes
# - Content: String
#
# [*newrelic_app_group*] The group of the New Relic agent installation directory (default: 'root').
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
# [*newrelic_record_sql*] When transaction tracer is on, SQL statements can optionally be recorded. The recorder has three modes, "off" which sends no
#                         SQL, "raw" which sends the SQL statement in its original form, and "obfuscated", which strips out numeric and string literals.
#                         (default: obfuscated).
# - Required: no
# - Content: 'obfuscated' | 'raw' | 'off'
#
# [*newrelic_environments*] New Relic applies settings in the common stanza to each of these environments. You can select other environments as the default
#                           by setting the newrelic.environment system property to the environment name. For example -Dnewrelic.environment=acceptance
#                           (default: production)
# - Required: no
# - Content: array of hashes
#
# Sample Usage:
#
# cegeka_newrelic::application_monitoring { 'newrelic application monitoring':
#   newrelic_version        => '2.18.0',
#   newrelic_app_root_dir   => '/opt/appserver',
#   newrelic_app_owner      => '<your app user>',
#   newrelic_app_group      => '<your app group>',
#   newrelic_license_key    => '<your license key>',
#   newrelic_app_name       => '<your app name>',
#   newrelic_agent_loglevel => '<loglevel>',
#   newrelic_record_sql     => '<type>',
#   newrelic_use_ssl        => true,
#   $newrelic_enable_cross_application_tracer=false,
#   newrelic_enable_distributed_tracing => true
#   newrelic_environments   => [
#                               { 'name' => 'acceptance', 'values' => { '<<' => '*default_settings', 'app_name' => 'My Application (Acceptance)' } },
#                               { 'name' => 'production', 'values' => { '<<' => '*default_settings' } }
#                              ]
# }
#
define cegeka_newrelic::application_monitoring(
  $ensure = present,
  $newrelic_version=undef,
  $newrelic_app_root_dir=undef,
  $newrelic_app_owner='root',
  $newrelic_app_group='root',
  $newrelic_license_key=undef,
  $newrelic_app_name='My Application',
  $newrelic_agent_loglevel='info',
  $newrelic_record_sql='obfuscated',
  $newrelic_use_ssl=false,
  $newrelic_enable_cross_application_tracer=false,
  $newrelic_enable_distributed_tracing=true,
  $newrelic_environments=[{ 'name' => 'production', 'values' => { '<<' => '*default_settings' } }],
  $newrelic_use_versioned_configfile=true,
) {

  if ($ensure == 'present' and $newrelic_version == undef) {
    fail('The version of the New Relic agent must be provided')
  }

  if ($ensure == 'present' and $newrelic_app_root_dir == undef) {
    fail('The root directory of the application server installation must be provided')
  }

  if ($ensure == 'present' and $newrelic_license_key == undef) {
    fail('The license key associated with your New Relic account must be provided')
  }

  if ! ($newrelic_agent_loglevel in ['off' , 'severe' , 'warning' , 'info' , 'fine' , 'finer' , 'finest']) {
    fail("${newrelic_agent_loglevel} is not one of valid predefined values for agent loglevels")
  }

  if ! ($newrelic_record_sql in ['obfuscated' , 'raw' , 'off']) {
    fail("${newrelic_record_sql} is not one of valid predefined values for record sql")
  }

  if $ensure == absent {
    $directory_ensure = absent
  }else{
    $directory_ensure = directory
  }
  case $newrelic_use_ssl {
    true, false: { $newrelic_use_ssl_real = $newrelic_use_ssl }
    default: {
      fail("cegeka_newrelic::Application_monitoring[${newrelic_use_ssl}]: parameter newrelic_use_ssl must be a boolean")
    }
  }

  file { "${newrelic_app_root_dir}/newrelic" :
    ensure => $directory_ensure,
    owner  => $newrelic_app_owner,
    group  => $newrelic_app_group,
  }

  file { "${newrelic_app_root_dir}/newrelic/logs" :
    ensure  => $directory_ensure,
    owner   => $newrelic_app_owner,
    group   => $newrelic_app_group,
    require => File["${newrelic_app_root_dir}/newrelic"],
  }

  file { "${newrelic_app_root_dir}/newrelic/extensions" :
    ensure  => $directory_ensure,
    owner   => $newrelic_app_owner,
    group   => $newrelic_app_group,
    require => File["${newrelic_app_root_dir}/newrelic"],
  }

  file { "${newrelic_app_root_dir}/newrelic/newrelic-${newrelic_version}.jar" :
    ensure  => $ensure,
    owner   => $newrelic_app_owner,
    group   => $newrelic_app_group,
    source  => "puppet:///modules/${module_name}/newrelic-${newrelic_version}.jar",
    require => File["${newrelic_app_root_dir}/newrelic"],
  }

  if $newrelic_use_versioned_configfile {
    file { "${newrelic_app_root_dir}/newrelic/newrelic.yml" :
      ensure  => $ensure,
      owner   => $newrelic_app_owner,
      group   => $newrelic_app_group,
      content => multitemplate( "${module_name}/application/newrelic.yml.${newrelic_version}.erb",
                                "${module_name}/application/newrelic.yml.erb",
                              ),
    }
  }else{
    file { "${newrelic_app_root_dir}/newrelic/newrelic.yml" :
      ensure  => $ensure,
      owner   => $newrelic_app_owner,
      group   => $newrelic_app_group,
      content => template("${module_name}/application/newrelic.yml.erb"),
    }
  }
}
