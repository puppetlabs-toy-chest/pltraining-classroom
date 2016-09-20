## Name: C:\Users\Administrator\Documents\WindowsPowerShell\Modules\alias\alias.psm1

Function validate_erb_func {
 [CmdletBinding()]
   Param($arg)
   $pwd = Get-Location
   $filename = "$pwd\$arg"
   $command = 'erb -P -x -T - $filename | ruby -c'
   iex "& $command"
}; Set-Alias validate_erb validate_erb_func

Function validate_yaml_func {
 [CmdletBinding()]
   Param($arg)
   $pwd = Get-Location
   $filename = "$pwd\$arg"
   $command = 'ruby -ryaml -e "YAML.load_file ''$filename''"'
   iex "& $command"
}; Set-Alias validate_yaml validate_yaml_func

export-modulemember -alias * -function *