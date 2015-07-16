# creates a user in the PE Console
#
define classroom::console::user ( $password, $role = 'Operators' ) {

  rbac_user { $name:
    ensure       => present,
    password     => $password,
    display_name => $name,
    email        => "${name}@puppetlabs.vm",
    roles        => $role,
  }
}
