class classroom::windows::alias {

  assert_private('This class should not be called directly')

  $ps_module_path = 'C:/Users/Administrator/Documents/WindowsPowerShell/Modules'
  $alias_dir      = "${ps_module_path}/alias"
  $psm_file       = 'alias.psm1'
  $psd_file       = 'alias.psd1'

  file { [$ps_module_path, $alias_dir] :
    ensure => directory,
  }

  file {"${alias_dir}/${psm_file}" :
    ensure  => file,
    source  => "puppet:///modules/classroom/windows/${psm_file}",
  }

  exec { "create_ps_datafile":
    command   => "New-ModuleManifest -Path ${alias_dir}/${psd_file} -ModuleToProcess ${alias_dir}/${psm_file}; Import-Module alias",
    creates   => "${alias_dir}/${psd_file}",
    provider  => powershell,
  }

}
