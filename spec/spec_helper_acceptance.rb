require 'puppetlabs_spec_helper/module_spec_helper'
require 'beaker-rspec'

rsync_to(master, 'spec/fixtures/modules/', '/etc/puppetlabs/code/modules')

sleep 100
sleep_until_puppetserver_started(master)
sleep_until_puppetdb_started(master)
sleep_until_nc_started(master)

# Install a blank presentation and dummy rakefile
on master, "mkdir -p /home/training/courseware"
rakefile = 
<<-EOS
  task :watermark do
    puts "This is a default rakefile for the classroom spec tests"
  end
EOS
create_remote_file(master, "/home/training/courseware/Rakefile", rakefile)
