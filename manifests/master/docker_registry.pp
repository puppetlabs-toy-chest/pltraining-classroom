class classroom::master::docker_registry {

  docker::image { 'registry:2':
  docker::run {'registry':
    image            => 'registry:2',
    ports            => ['5000:5000'],
  }

  # Cache the centos image in the local registry
  $image_name = "centos:${::operatingsystemmajrelease}"
  docker::image { $image_name: }

  # Tag image
  exec { "docker tag ${image_name} ${::fqdn}:5000/${image_name}":
    path    => '/usr/bin/',
    require => Docker::Image[$image_name],
  }
  exec { "docker push ${::fqdn}:5000/${image_name}":
    path    => '/usr/bin/',
    require => Exec["docker tag ${image_name} ${::fqdn}:5000/${image_name}"]
  }
}
