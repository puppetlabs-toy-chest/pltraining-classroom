class classroom::agent::yum_repos {
  $classroom::repos.each |$repo, $value| {
    yumrepo { "${repo}_cache":
      name      => "${repo}_cache",
      ensure    => present,
      baseurl   => "https://master.puppetlabs.vm:8140/packages/yum/${repo}/${::architecture}/",
      priority  => '1',
      enabled   => true,
      sslverify => '0',
    }
  }
}
