require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet-utils'
require 'hiera-puppet-helper'

# Uncomment this to show coverage report, also useful for debugging
#at_exit { RSpec::Puppet::Coverage.report! }

RSpec.configure do |config|
  config.formatter = 'documentation'
  config.mock_with :rspec
  congig.expect_with :rspec do |c|
    # ...or explicitly enable both
    c.syntax = [:should, :expect]
  end
end
