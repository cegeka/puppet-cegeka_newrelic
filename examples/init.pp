class { 'newrelic::server_monitoring':
  newrelic_license_key => '1234567890',
}

newrelic::application_monitoring { 'app monitoring':
  newrelic_version      => '3.5.1',
  newrelic_app_root_dir => '/opt/appserver',
  newrelic_license_key  => '1234567890'
}
