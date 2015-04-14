# Manage yum (and maybe someday apt) repositories in the classroom.
class classroom::repositories (
  $manageyum    = $classroom::manageyum,
  $offline      = $classroom::offline,
  $repositories = $classroom::repositories,
) inherits classroom {

  if $manageyum and $::osfamily == 'RedHat' {
    yumrepo { $repositories:
      enabled => $offline ? {
        true  => '0',
        false => '1',
      },
    }
    # Other classes *must not* define epel otherwise they can potentially 
    # enable it which will potentially break offline classes
    class { 'epel':
      epel_enabled => ! $offline,
    }
  }

}
