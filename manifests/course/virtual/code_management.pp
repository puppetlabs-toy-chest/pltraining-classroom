class classroom::course::virtual::code_management (
  $session_id = $classroom::params::session_id,
) inherits classroom::params {

  if $role == 'master' {
    # Classroom for the codemanagement course
    class { 'puppetfactory':
      # Put students' puppetcode directories somewhere less distracting
      puppetcode => '/var/opt/puppetcode',
      session_id       => $session_id,
    }

    class { 'r10k':
      remote => 'https://github.com/puppetlabs-education/classroom-control.git',
    }
  }

  include r10k::mcollective
  include puppet_enterprise::profile::mcollective::peadmin
}
