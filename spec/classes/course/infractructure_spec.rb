require 'spec_helper'

describe 'classroom::course::infrastructure' do

  context "applied to master" do
    let(:node) { 'master.puppetlabs.vm' }

    it { should compile }
  end

  context "applied to agent" do
    let(:node) { 'training.puppetlabs.vm' }

    it { should compile }
  end
end
