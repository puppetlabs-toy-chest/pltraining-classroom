# Host the local yum cache alongside the puppet packages
class classroom::master::yum_server {
  file { $classroom::repo_base_path:
    ensure => directory,
  }
  $classroom::repos.each |$repo_name,$repo_path| {
    file {"${classroom::repo_base_path}/${repo_name}":
      ensure  => link,
      target  => $repo_path,
      require => File[$classroom::repo_base_path]
    }
  }
}
