require 'spec_helper'

describe 'classroom::course::puppetize' do

  parameter_matrix = [
    { :offline => true},
    { :offline => false},
  ]
  parameter_matrix.each do |params|
    context "applied to master: #{params.to_s}" do
      let(:pre_condition) {
         "$puppetmaster = 'master.puppetlabs.vm'
          $ec2_metadata = undef
          service { 'pe-puppetserver':
            ensure => running,
         }" + GLOBAL_PRE + VIRTUAL_PRE
      }
      let(:node) { 'master.puppetlabs.vm' }
      let(:facts) { {
        :servername => 'master.puppetlabs.vm'
      } }
      let(:params) { params }

      it { should compile }
    end

    context "applied to agent: #{params.to_s}" do
      let(:pre_condition) {
        "$puppetmaster = 'master.puppetlabs.vm'
         $ec2_metadata = undef
         service { 'pe-puppetserver':
           ensure => running,
         }" + GLOBAL_PRE + VIRTUAL_PRE
      }
      let(:node) { 'agent.puppetlabs.vm' }
      let(:facts) { {
        :servername => 'master.puppetlabs.vm'
      } }
      let(:params) { params }
      let(:node) { 'master.puppetlabs.vm' }

      it { should compile }
    end
  end
end
