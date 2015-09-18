class classroom::master::yum_server {
  file { $classroom::repo_base_path:
    ensure => directory,
  }
  $classroom::repos.each |$repo_name,$repo_path| {
    file {"${repo_base_path}/${repo_name}":
      ensure  => link,
      target  => $repo_path,
      require => File[$repo_base_path]
    }
  }
}
