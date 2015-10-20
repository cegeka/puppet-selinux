# Class: selinux::config
#
# Description
#  This class is designed to configure the system to use SELinux on the system
#
# Parameters:
#  - $mode (enforcing|permissive|disabled) - sets the operating state for SELinux.
#  - $mode (targeted|minimum|mls) - sets the operating type for SELinux.
#
# Actions:
#  Configures SELinux to a specific state (enforced|permissive|disabled and targeted|minimum|mls)
#
# Requires:
#  This module has no requirements
#
# Sample Usage:
#  This module should not be called directly.
#
class selinux::config (
  $mode = $::selinux::mode,
  $type = $::selinux::type,
) {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  # Validations
  validate_re($mode, ['^enforcing$', '^permissive$', '^disabled$'], "Valid modes are enforcing, permissive, and disabled.  Received: ${mode}")
  validate_re($type, ['^targeted$', '^minimum$', '^mls$'], "Valid modes are targeted, minimum, and mls.  Received: ${type}")

  file { $selinux::params::sx_mod_dir:
    ensure => directory,
  }

  file_line { "set-selinux-config-to-${mode}":
    path  => '/etc/selinux/config',
    line  => "SELINUX=${mode}",
    match => '^SELINUX=\w+',
  }

  file_line { "set-selinux-config-type-to-${type}":
    path  => '/etc/selinux/config',
    line  => "SELINUXTYPE=${type}",
    match => '^SELINUXTYPE=\w+',
  }

  case $mode {
    permissive, disabled: {
      $sestatus = '0'
      if $mode == 'disabled' and defined('$::selinux_current_mode') and $::selinux_current_mode == 'permissive' {
        notice('A reboot is required to fully disable SELinux. SELinux will operate in Permissive mode until a reboot')
      }
    }
    enforcing: {
      $sestatus = '1'
    }
    default : {
      fail('You must specify a mode (enforced, permissive, or disabled) for selinux operation')
    }
  }

  exec { "change-selinux-status-to-${mode}":
    command => "setenforce ${sestatus}",
    unless  => "getenforce | grep -qi \"${mode}\\|disabled\"",
    path    => '/bin:/usr/bin:/usr/sbin',
  }
}
