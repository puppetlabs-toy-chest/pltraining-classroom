function classroom::offline_gem_installer(Array $gems, String $provider) {
  $gems.each |Integer $index, String $gemname| {
    package { $gemname:
      ensure          => present,
      install_options => '-l',
      source          => "/var/cache/rubygems/gems/${gemname}-[0-9]*.gem",
      provider        => $provider,
    }

    if $index > 0 {
      $prevgemname = $gems[$index - 1]

      # Set the proper ordering dependency
      Package[$prevgemname] -> Package[$gemname]
    }
  }
}
