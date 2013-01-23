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
  
  describe 'setup commands on Debian based systems' do
    let(:facts) { { :osfamily  => 'Debian' } }
    
    it { should contain_exec('add_newrelic_repo').with_command('/usr/bin/wget -O /etc/apt/sources.list.d/newrelic.list http://download.newrelic.com/debian/newrelic.list') }
    it { should contain_exec('add_newrelic_repo_key').with_command('/usr/bin/apt-key adv --keyserver hkp://subkeys.pgp.net --recv-keys 548C16BF') }
    it { should contain_exec('update_repos').with_command('/usr/bin/apt-get update -y -qq') }
  end
  
  describe 'setup commands on RHEL based systems' do
    let(:facts) { { :osfamily  => 'RedHat' } }
    
    it { should contain_package('newrelic-repo').with_ensure('present') }
    it { should contain_package('newrelic-repo').with_provider('rpm') }
    it { should contain_package('newrelic-repo').with_source('http://download.newrelic.com/pub/newrelic/el5/i386/newrelic-repo-5-3.noarch.rpm') }
    it { should contain_exec('update_repos').with_command('/bin/true') }
  end
end