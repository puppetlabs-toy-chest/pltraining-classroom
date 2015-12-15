source "https://rubygems.org"

group :test do
    gem "rake"
    gem "puppet", ENV['PUPPET_VERSION'] || '~> 4.2.2'
    gem "rspec-puppet", :git => 'https://github.com/rodjek/rspec-puppet.git'
    gem "puppetlabs_spec_helper"
    gem 'rspec-puppet-utils', :git => 'https://github.com/Accuity/rspec-puppet-utils.git'
    gem 'hiera-puppet-helper', :git => 'https://github.com/bobtfish/hiera-puppet-helper.git'
    gem "metadata-json-lint"
    gem 'puppet-syntax'
    gem 'puppet-lint'
end

group :development do
    gem "travis"
    gem "travis-lint"
    gem "puppet-blacksmith"
    gem "guard-rake"
    gem "pry"
end
