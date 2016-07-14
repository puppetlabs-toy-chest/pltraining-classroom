class classroom::master::codemanager {
  assert_private('This class should not be called directly')

  if(versioncmp($::pe_server_version, '2016.1.1') > 0) {
    # <Workaround for PE-15399>
    pe_hocon_setting { 'file-sync.client.stream-file-threshold':
      path    => '/etc/puppetlabs/puppetserver/conf.d/file-sync.conf',
      setting => 'file-sync.client.stream-file-threshold',
      value   => 512,
    }
    # </Workaround>
  }
}
