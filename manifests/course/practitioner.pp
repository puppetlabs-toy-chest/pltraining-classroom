# This is a wrapper class for the legacy config
#
class classroom::course::practitioner (
  $offline            = undef,
  $manage_yum         = undef,
  $time_servers       = undef,
  $jvm_tuning_profile = undef,
  $event_id           = undef,
  $event_pw           = undef,
  $version            = undef,
) {
  # just wrap the classroom class
  class { 'classroom_legacy::course::practitioner':
    offline            => $offline,
    manage_yum         => $manage_yum,
    time_servers       => $time_servers,
    jvm_tuning_profile => $jvm_tuning_profile,
    event_id           => $event_id,
    event_pw           => $event_pw,
    version            => $version,
  }
}
