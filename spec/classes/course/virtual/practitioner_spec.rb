require 'spec_helper'

describe 'classroom::course::virtual::practitioner' do

  parameter_matrix = [
    { :offline => true, :control_owner => 'puppetlabs-education' },
    { :offline => false, :control_owner => 'puppetlabs-education' }
  ]
  parameter_matrix.each do |params|
    context "applied to master: #{params.to_s}" do
      let(:pre_condition) {
         "class classroom { $offline = true }
          include classroom
          $puppetmaster = 'master.puppetlabs.vm'
          $ec2_metadata = undef
          service { 'pe-puppetserver':
            ensure => running,
         }" + GLOBAL_PRE
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
        "class classroom { $offline = true }
         include classroom
         $puppetmaster = 'master.puppetlabs.vm'
         $ec2_metadata = undef
         service { 'pe-puppetserver':
           ensure => running,
         }" + GLOBAL_PRE
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
