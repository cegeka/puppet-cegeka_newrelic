#!/usr/bin/env rspec

require 'spec_helper'

describe 'newrelic::server_monitoring' do

  context 'without a license_key specified' do

    it {
    	expect { subject }.to raise_error(
      	Puppet::Error, /The license key associated with your New Relic account must be provided/
  	)}

  end

  context 'without a valid loglevel' do

		let (:params) { { :newrelic_license_key => '1234567890' , :newrelic_loglevel => 'vverbosedebug'} }

		it {
    	expect { subject }.to raise_error(
      	Puppet::Error, /vverbosedebug is not one of valid predefined values for loglevels/
  	)}

	end

	context 'with a valid license_key' do
	
		let (:params) { { :newrelic_license_key => '1234567890' } }

		it { should contain_class 'newrelic::server_monitoring' }
    it { should contain_file('/etc/newrelic/nrsysmond.cfg') }
    it { should contain_package('newrelic-sysmond').with_ensure('present') }
    it { should contain_service('newrelic-sysmond').with_ensure('running') }

	end

	context 'with a valid license_key and loglevel' do

		let (:params) { { :newrelic_license_key => '1234567890', :newrelic_loglevel => 'debug' } }

    it { should contain_class 'newrelic::server_monitoring' }
		it { should contain_file('/etc/newrelic/nrsysmond.cfg') }
		it { should contain_package('newrelic-sysmond').with_ensure('present') }
	  it { should contain_service('newrelic-sysmond').with_ensure('running') }

	end

end
