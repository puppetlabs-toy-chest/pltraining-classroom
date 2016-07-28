require 'beaker-rspec'

on default, puppet('module', 'install', 'pltraining-classroom', '--modulepath=/etc/puppetlabs/code/modules')
copy_module_to(default, source: '.', module_name: 'classroom', target_module_path: '/etc/puppetlabs/code/modules')

# Install a blank presentation and dummy rakefile
on master, "mkdir -p /home/training/courseware"
rakefile = 
<<-EOS
  task :watermark do
    puts "This is a default rakefile for the classroom spec tests"
  end
EOS
create_remote_file(master, "/home/training/courseware/Rakefile", rakefile)
