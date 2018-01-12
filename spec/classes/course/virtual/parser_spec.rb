require 'spec_helper'

describe 'classroom::course::virtual::parser' do

  context "applied to master" do
    let(:pre_condition) {
      "$puppetmaster = 'master.puppetlabs.vm'
       $ec2_metadata = undef
       service { 'pe-puppetserver':
         ensure => running,
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
       }" + GLOBAL_PRE
    }
    let(:node) { 'agent.puppetlabs.vm' }
    let(:facts) { {
      :servername => 'master.puppetlabs.vm'
    } }

    it { should compile }
  end
end
