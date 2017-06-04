require 'spec_helper'

describe 'classroom::agent' do
  before(:each) {
    Puppet::Parser::Functions.newfunction(:assert_private) { |args| true }
  }

  let(:node) { 'agent.puppetlabs.vm' }
  let(:facts) { {
    :osfamily   => 'RedHat',
    :servername => 'master.puppetlabs.vm',
  } }
  let(:pre_condition) do
    #<--PRE
    #  class { 'classroom::params':
    #    $machine_name => 'pirate.puppetlabs.vm',
    #  }
    #  include classroom::params
    #PRE
    [
      'include classroom',
      'include classroom::params'
    ]
  end

  it { is_expected.to contain_file("/etc/puppet")
    .with({
      "ensure"  => "absent",
      "recurse" => true,
      "force"   => true,
    })
  }

  it { is_expected.to contain_classroom__user("$::classroom::params::machine_name")
    .with({
      "key"         => "$::root_ssh_key",
      "password"    => "$classroom::password",
      "consolepw"   => "$classroom::consolepw",
      "manage_repo" => "$classroom::manage_repos",
    })
  }

  it { is_expected.to contain_classroom__agent__workdir("$classroom::workdir")
    .with({
      "ensure"   => "present",
      "username" => "$classroom::params::machine_name",
      "require"  => "Class[classroom::agent::git]",
    })
  }
end
