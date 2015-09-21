require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet-utils'
require 'hiera-puppet-helper'

# Uncomment this to show coverage report, also useful for debugging
#at_exit { RSpec::Puppet::Coverage.report! }

RSpec.configure do |c|
  c.formatter = 'documentation'
  c.mock_with :rspec
  c.expect_with :rspec do |conf|
    # ...or explicitly enable both
    c.syntax = [:should, :expect]
  end
end
