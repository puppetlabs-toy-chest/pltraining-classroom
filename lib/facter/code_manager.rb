Facter.add('code_manager_enabled') do
  setcode do
    File.file?('/etc/puppetlabs/puppetserver/conf.d/code-manager.conf')
  end
end
