require 'spec_helper_acceptance'

describe 'classroom' do
    before(:all) do
      sleep_until_puppetserver_started(master)
      on master, "echo 'node default { include classroom }' > /etc/puppetlabs/code/environments/production/manifests/site.pp"
    end


    it 'runs with changes' do
      on master, "puppet agent -t", :acceptable_exit_codes => [2]
    end

    it 'run idempotently' do
      on master, "puppet agent -t", :acceptable_exit_codes => [0]
    end

end
