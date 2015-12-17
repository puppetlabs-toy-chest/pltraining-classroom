require 'spec_helper'

describe 'classroom' do

  context 'applied to the master' do
    let(:node) { 'master.puppetlabs.vm' }
    let(:facts) { { :pe_server_version => '2015.3.0', :hostname => 'master' } }

    it { should compile }
  end

  context 'applied to an offline master' do
    let(:node) { 'master.puppetlabs.vm' }
    let(:facts) { { :pe_server_version => '2015.3.0' } }
    let(:params) { {:offline => true } }

    it { should compile }
  end

  context 'applied to the agent' do
    let(:node) { 'agent.puppetlabs.vm' }

    it { should compile }
  end

  context 'applied to an offline agent' do
    let(:node) { 'agent.puppetlabs.vm' }
    let(:params) { {:offline => true } }

    it { should compile }
  end

end
