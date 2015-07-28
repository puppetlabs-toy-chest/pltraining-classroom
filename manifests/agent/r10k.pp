class classroom::agent::r10k {
  assert_private('This class should not be called directly')

  class { '::r10k':
    sources => {
      'puppet' => {
        'remote'  => $classroom::r10k_remote,
        'basedir' => $classroom::r10k_basedir,
        'prefix'  => false,
      },
    },
    version => present,
  }
}
