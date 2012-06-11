#!/usr/bin/env rspec

require 'spec_helper'

describe 'newrelic' do
  it { should contain_class 'newrelic' }
end
