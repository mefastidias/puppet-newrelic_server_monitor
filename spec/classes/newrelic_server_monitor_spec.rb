#!/usr/bin/env rspec
require 'spec_helper'

describe 'newrelic_server_monitor' do
  let(:params) { { :license_key => 'VALIDLICENSEKEY' } }
  let(:facts) { { :osfamily => 'debian' } }
    
  it { should contain_package('newrelic-sysmond').with_ensure('present') }
  
  it { should contain_service('newrelic-sysmond').with_enable(true) }
  it { should contain_service('newrelic-sysmond').with_ensure('running') }
    
  describe 'requires a license_key' do
    let(:params) { {} }
    
    it { expect{ subject }.to raise_error(/^The license_key parameter must be defined./) }
  end
  
  describe 'for operating system family unsupported' do
    let(:facts) { { :osfamily  => 'unsupported' } }

    it { expect{ subject }.to raise_error(/^The newrelic_server_monitor module does not support unsupported./)}
  end
  
  describe 'with use_latest option set to true' do
    let(:params) { { :license_key => 'VALIDLICENSEKEY', :use_latest => true } }

    it { should contain_package('newrelic-sysmond').with_ensure('latest') }
  end
end