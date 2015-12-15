class classroom::master::docker_registry {
  class {'docker':
    extra_parameters => '--insecure-registry localhost:5000',
  }

  docker::image { 'registry':
    image_tag => '2',
  }

  docker::run {'registry':
    image            => 'registry:2',
    ports            => ['5000:5000'],
  }

  # Cache the centos image in the local registry
  docker::image { 'centos':
    image_tag => $::operatingsystemmajrelease,
  }

  # Tag image
  $image_name = "centos:${::operatingsystemmajrelease}"
  exec { "docker tag ${image_name} localhost:5000/${image_name}":
    path    => '/usr/bin/:/bin',
    unless  => "docker images | grep localhost:5000/centos",
    require => Docker::Image['centos'],
  }
  exec { "docker push localhost:5000/${image_name}":
    path    => $::path,
    unless  => "curl -Is -X GET http://localhost:5000/v2/centos/manifests/${::operatingsystemmajrelease} | grep '200 OK'",
    require => Exec["docker tag ${image_name} localhost:5000/${image_name}"]
  }
}
