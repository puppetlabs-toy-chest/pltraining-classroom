require 'spec_helper'

describe 'classroom::course::virtual::hiera' do

  context "applied to master" do
    let(:pre_condition) {
      "service { 'pe-puppetserver':
          ensure => running,
        }" + GLOBAL_PRE
    }
    let(:node) { 'master.puppetlabs.vm' }
    let(:facts) { {
      :servername => 'master.puppetlabs.vm',
      :puppetlabs_class => 'hiera',
    } }

    it { should compile }
  end

  context "applied to agent" do
    let(:node) { 'agent.puppetlabs.vm' }
    let(:facts) { {
      :servername => 'master.puppetlabs.vm'
    } }

    it { should compile }
  end
end
