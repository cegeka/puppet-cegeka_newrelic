require 'spec_helper_acceptance'

describe 'newrelic::server_monitoring' do

  describe 'running puppet code' do
    it 'should work with no errors' do
      pp = <<-EOS
        include yum
        include stdlib
        include stdlib::stages
        include profile::package_management
        class { 'cegekarepos' : stage => 'setup_repo' }
        
        Yum::Repo <| title == 'newrelic' |>

        class { 'newrelic::server_monitoring':
           newrelic_license_key => '5703d3eff5eb433a9a99d737aa0dcb4d6d42fbe1', ## dummy key
        }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe file '/etc/newrelic/nrsysmond.cfg' do
      it { is_expected.to be_file }
      its(:content) { should match /5703d3eff5eb433a9a99d737aa0dcb4d6d42fbe1/ }
    end

    describe package('newrelic-sysmond') do
      it { should be_installed }
    end 

    describe service('newrelic-sysmond') do
      it { should be_enabled }
    end
  end

  describe 'running puppet code with debug level' do
    it 'should work with no errors' do
      pp = <<-EOS
        include yum
        include stdlib
        include stdlib::stages
        include profile::package_management
        class { 'cegekarepos' : stage => 'setup_repo' }
        
        Yum::Repo <| title == 'newrelic' |>

        class { 'newrelic::server_monitoring':
           newrelic_license_key => '5703d3eff5eb433a9a99d737aa0dcb4d6d42fbe1', ## dummy key
           newrelic_loglevel    => 'debug'
        }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe file '/etc/newrelic/nrsysmond.cfg' do
      it { is_expected.to be_file }
      its(:content) { should match /5703d3eff5eb433a9a99d737aa0dcb4d6d42fbe1/ }
      its(:content) { should match /debug/ }
    end

    describe package('newrelic-sysmond') do
      it { should be_installed }
    end

    describe service('newrelic-sysmond') do
      it { should be_enabled }
    end
  end
end
