require 'spec_helper'

describe 'classroom::course::infrastructure' do

  context "applied to master" do
    let(:facts) {{
      :ipaddress_docker0 => '172.16.42.1'
    }}
    let(:node) { 'master.puppetlabs.vm' }

    it { should compile }
  end

  context "applied to agent" do
    let(:facts) {{
      :ipaddress_docker0 => '172.16.42.1'
    }}
    let(:node) { 'training.puppetlabs.vm' }

    it { should compile }
  end
end
