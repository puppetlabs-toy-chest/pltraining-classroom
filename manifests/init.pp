# Configure the training classroom environment.
#
# classroom::agent
#   * set up the agent with an sshkey for root
#   * set up a git working directory for the user
#   * point a git remote to the repo on the puppet master
#   * export a classroom::user account
#       * this depends on a root_ssh_key fact so this user
#         account won't be exported properly on first run
#
# classroom::master
#   * prepares the master's environment
#   * creates a git repository root
#   * creates an environment root for checking out working copies
#   * instantiate all exported classroom::users
#       * creates a shell user with ssh key
#       * creates a puppet.conf environment fragment
#       * creates a bare repository in repo root
#       * checks out a working copy in the environments root
#
#
# $offline   : Configure NTP (and other services) to run in standalone mode
#              Sets up local gitea git service.
# $role      : What classroom role this node should play
#
class classroom (
  $offline         = $classroom::params::offline,
  $role            = $classroom::params::role,
  $manage_yum      = $classroom::params::manage_yum,
  $manage_repos    = $classroom::params::manage_repos,
  $manage_selinux  = $classroom::params::manage_selinux,
  $time_servers    = $classroom::params::time_servers,
  $repositories    = $classroom::params::repositories,
) inherits classroom::params {
  validate_bool($offline)
  validate_bool($manage_yum)
  validate_bool($manage_repos)
  validate_bool($manage_selinux)
  validate_array($time_servers)

  case $role {
    'master'   : { include classroom::master     }
    'agent'    : { include classroom::agent      }
    'adserver' : { include classroom::agent      }
    'proxy'    : { include classroom::proxy      }
    default    : { fail("Unknown role: ${role}") }
  }

  include classroom::repositories

  # trust classroom CA so students can download from the master
  include classroom::cacert
}
