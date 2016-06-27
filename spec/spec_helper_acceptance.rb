require 'beaker-rspec'

on default, puppet('module', 'install', 'pltraining-classroom', '--modulepath=/etc/puppetlabs/code/modules')
copy_module_to(default, source: '.', module_name: 'classroom')
