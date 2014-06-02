#!/usr/bin/env rspec

require 'spec_helper'

describe 'newrelic::application_monitoring' do

  let (:title) { 'newrelic application monitoring' }

  context 'without a version specified' do

		it {
      expect { subject }.to raise_error(
        Puppet::Error, /The version of the New Relic agent must be provided/
    )}

	end

  context 'without an installation root directory specified' do

    let (:params) { { :newrelic_version => '2.18.0' } }

		it {
      expect { subject }.to raise_error(
        Puppet::Error, /The root directory of the application server installation must be provided/
    )}

	end

  context 'without a license_key specified' do

		let (:params) { { :newrelic_version => '2.18.0', :newrelic_app_root_dir => '/opt/appserver' } }

    it {
    	expect { subject }.to raise_error(
      	Puppet::Error, /The license key associated with your New Relic account must be provided/
  	)}

  end

  context 'without a valid agent loglevel' do

		let (:params) { { :newrelic_version => '2.18.0',
                      :newrelic_app_root_dir => '/opt/appserver',
											:newrelic_license_key => '1234567890' ,
											:newrelic_agent_loglevel => 'vverbosedebug'} }

		it {
    	expect { subject }.to raise_error(
      	Puppet::Error, /vverbosedebug is not one of valid predefined values for agent loglevels/
  	)}

	end

  context 'without a valid record_sql value' do

		let (:params) { { :newrelic_version => '2.18.0',
                      :newrelic_app_root_dir => '/opt/appserver',
                      :newrelic_license_key => '1234567890' ,
                      :newrelic_agent_loglevel => 'fine',
		:newrelic_record_sql => 'bla'} }

		it {
      expect { subject }.to raise_error(
        Puppet::Error, /bla is not one of valid predefined values for record sql/
    )}
  end

  context 'without a valid use_ssl value' do

		let (:params) { { :newrelic_version => '2.18.0',
                      :newrelic_app_root_dir => '/opt/appserver',
                      :newrelic_license_key => '1234567890' ,
                      :newrelic_agent_loglevel => 'fine',
											:newrelic_use_ssl => 'bla'} }

		it {
      expect { subject }.to raise_error(
        Puppet::Error, /parameter newrelic_use_ssl must be a boolean/
    )}

	end

	context 'with a valid version, installation directory and license_key' do

		let (:params) { { :newrelic_version => '2.18.0',
                      :newrelic_app_root_dir => '/opt/appserver',
											:newrelic_license_key => '1234567890' } }

		it { should contain_file '/opt/appserver/newrelic' }
		it { should contain_file '/opt/appserver/newrelic/newrelic-2.18.0.jar' }
		it { should contain_file '/opt/appserver/newrelic/newrelic.yml' }

	end

	context 'with a valid version, installation directory, application owner and group, license_key record sql option and agent loglevel' do

		let (:params) { { :newrelic_version => '2.20.0',
                      :newrelic_app_root_dir => '/opt/appserver',
											:newrelic_app_owner => 'newrelic',
											:newrelic_app_group => 'newrelic',
											:newrelic_license_key => '1234567890',
                      :newrelic_record_sql => 'raw',
											:newrelic_agent_loglevel => 'finer' } }

		it do
    	should contain_file('/opt/appserver/newrelic').with({
      	'ensure' => 'directory',
      	'owner'  => 'newrelic',
      	'group'  => 'newrelic',
    	})
  	end
		it do
      should contain_file('/opt/appserver/newrelic/newrelic-2.20.0.jar').with({
        'ensure' => 'file',
        'owner'  => 'newrelic',
        'group'  => 'newrelic',
      })
    end
		it do
      should contain_file('/opt/appserver/newrelic/newrelic.yml').with({
        'ensure' => 'file',
        'owner'  => 'newrelic',
        'group'  => 'newrelic',
      })
    end

	end

end
