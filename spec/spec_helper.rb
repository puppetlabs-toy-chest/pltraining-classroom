require 'puppetlabs_spec_helper/module_spec_helper'

RSpec.configure do |c|
  # Adds to the built in defaults from rspec-puppet
  c.default_facts = {
    :ipaddress                 => '127.0.0.1',
    :kernel                    => 'Linux',
    :architecture => 'x86_64',
    :operatingsystem           => 'CentOS',
    :operatingsystemrelease    => '7.2.1211',
    :operatingsystemmajrelease => '7',
    :osfamily                  => 'RedHat',
    :path                      => '/opt/puppetlabs/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/opt/puppetlabs/bin',
    :pe_concat_basedir         => '/opt/puppetlabs/puppet/cache/pe_concat',
    :pe_server_version => '2016.4.0',
    :aio_agent_version => '1.7.1',
    :puppetversion => '4.7.0',
    :pe_version => '2016.4',
    :platform_tag => 'el-7-x86_64',
    :is_pe => true,
    :kernelversion => '3.10.0',
    :memorysize => '16.00 GB',
    :processorcount => '4',
    :is_virtual => true,
    :root_ssh_key => 'foo',
    :pe_build => '2016.4',
    :classroom_vm_release => '5.7',
    :puppetserver => 'master.puppetlabs.vm',
    :staging_http_get => '/staging',
    :os => {
      :selinux => {
        :enabled => false
      },
      :family => 'RedHat',
      :release  => {
        :major => '7'
      }
    }
  }
  c.after(:suite) do
    RSpec::Puppet::Coverage.report!
  end
end

GLOBAL_PRE = "
define pe_hocon_setting (
  $ensure = '',
  $path = '',
  $setting = '',
  $value = '',
){}
define pe_ini_setting (
  $ensure = '',
  $path = '',
  $section = '',
  $setting = '',
  $value = '',
){}
define puppet_enterprise::mcollective::client (
  $ensure           = '',
  $activemq_brokers = [],
  $keypair_name     = '',
  $create_user      = true,
  $logfile          = '',
  $stomp_password   = '',
  $stomp_port       = '',
  $stomp_user       = ''
) {}
class pe_repo::platform::el_6_i386 {}
class pe_repo::platform::ubuntu_1404_amd64 {}
class pe_repo::platform::windows_x86_64 {}
"

