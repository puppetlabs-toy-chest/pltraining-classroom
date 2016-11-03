require 'spec_helper'

describe 'classroom::course::virtual::code_management' do

  context "applied to master" do
    let(:pre_condition) {
      "service { 'pe-puppetserver':
          ensure => running,
        }
        package {'r10k':
          ensure => present,
        }" + GLOBAL_PRE
    }
    let(:node) { 'master.puppetlabs.vm' }
    let(:facts) { {
      :servername => 'master.puppetlabs.vm'
    } }

    it { should compile }
  end

  context "applied to agent" do
    let(:pre_condition) {
      "service { 'pe-puppetserver':
          ensure => running,
        }
        package {'r10k':
          ensure => present,
        }" + GLOBAL_PRE
    }
    let(:node) { 'agent.puppetlabs.vm' }
    let(:facts) { {
      :servername => 'master.puppetlabs.vm'
    } }

    it { should compile }
  end
end
