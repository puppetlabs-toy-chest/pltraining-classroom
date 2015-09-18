require 'spec_helper'

courses = [
  'classroom::course::windows',
  'classroom::course::practitioner',
  'classroom::course::infrastructure',
  'classroom::course::fundamentals',
  'classroom::course::architect'
]

courses.each do |course|
  describe course do
    let(:facts) { {
      :osfamily => 'RedHat',
      :operatingsystem => 'CentOS',
      :fqdn => 'node.puppetlabs.vm',
      :clientcert => 'node.puppetlabs.vm',
      :aio_agent_version => '1.2.2',
      :operatingsystemrelease => '6.6',
      :augeas => {
        'version' => "1.4.0"
      },
      :facterversion => '3.0.2',
      :kernel => 'Linux',
      :kernelmajversion => '2.6',
      :kernelrelease => '2.6.32-504.8.1.el6.x86_64',
      :kernelversion => '2.6.32',
      
      :os => {
        'architecture' => "x86_64",
        'family' => "RedHat",
        'hardware' => "x86_64",
        'name' => "CentOS",
        'release' => {
          'full' => "6.6",
          'major' => "6",
          'minor' => "6"
        },
        'selinux' => {
          'enabled' => false
        }
      }}}
  
    it { should compile }
  end
end