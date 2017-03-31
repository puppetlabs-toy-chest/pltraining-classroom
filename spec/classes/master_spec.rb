require 'spec_helper'

describe 'classroom::master' do
  context 'with defaults for all parameters' do
    before(:each) {
      Puppet::Parser::Functions.newfunction(:assert_private) { |args|
        true
      }
    }

    it { is_expected.to contain_function(:assert_private) }
    it { is_expected.to contain_class('classroom::master::hiera') }
    it { is_expected.to contain_ini_setting('environment timeout') }

    context 'online master' do
      let(:node) { 'master.example.com' }
      let(:facts) { {
        :servername         => 'time.nist.gov',
        :classroom__offline => false,
        :pe_server_version  => '2016.4.1',
      } }
      let(:params) { { } }
      let(:pre_condition) do
        [ 'include pe_repo::platform::el_6_i386',
          'include pe_repo::platform::windows_x86_64' ]
      end

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_file("/usr/bin/pip-python").with({
          'ensure' => "link",
          'target' => "/usr/bin/pip",
        })
      }

      it { is_expected.to contain_ini_setting("environment timeout").with({
          'ensure'  => "present",
          'path'    => "/etc/puppetlabs/puppet/puppet.conf",
          'section' => "main",
          'setting' => "environment_timeout",
          'value'   => "0",
        })
      }

      it { is_expected.to contain_file("/etc/puppetlabs/code/environments/production/manifests/classroom.pp")
        .with({
          'ensure' => "file",
          'source' => "puppet:///modules/classroom/classroom.pp",
        })
      }

      it { is_expected.to contain_file("/etc/puppetlabs/code/environments").with({
          'ensure' => "directory",
          'mode'   => '1777',
        })
      }
    end

    context 'offline master' do
      let(:node) { 'master.example.com' }
      let(:facts) { {
        :servername         => 'time.nist.gov',
        :classroom__offline => 'true',
        :pe_server_version  => '2016.4.1',
      } }
      let(:params) { { } }
      let(:pre_condition) do
        [ 'include pe_repo::platform::el_6_i386',
          'include pe_repo::platform::windows_x86_64',
          'include classroom',
	  'include classroom::master::gitea' ]
      end

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_file("/usr/bin/pip-python")
        .with({
          'ensure' => "link",
          'target' => "/usr/bin/pip",
        })
      }

      ['/root/.gemrc', '/opt/puppetlabs/puppet/etc/gemrc'].each do |x| it {
        is_expected.to contain_file(x).with('ensure' => 'file') }
      end

      it { is_expected.to contain_file_line('/root/.gemrc')
        .with({
          'ensure'            => "absent",
          'path'              => "/root/.gemrc",
          'match'             => "- https://rubygems.org",
          'match_for_absence' => true,
        })
      }

      it { is_expected.to contain_file_line('/opt/puppetlabs/puppet/etc/gemrc')
        .with({
          'ensure'            => "absent",
          'path'              => "/opt/puppetlabs/puppet/etc//gemrc",
          'match'             => "- https://rubygems.org",
          'match_for_absence' => true,
        })
      }

      it { is_expected.to contain_ini_setting("environment timeout")
        .with({
          'ensure'  => "present",
          'path'    => "/etc/puppetlabs/puppet/puppet.conf",
          'section' => "main",
          'setting' => "environment_timeout",
          'value'   => "0",
        })
      }

      it { is_expected.to contain_file("/etc/puppetlabs/code/environments/production/manifests/classroom.pp")
        .with({
          'ensure' => "file",
          'source' => "puppet:///modules/classroom/classroom.pp",
        })
      }
  
      it { is_expected.to contain_file("/etc/puppetlabs/code/environments").with({
          'ensure' => "directory",
          'mode'   => "1777",
        })
      }
    end
  end
end
