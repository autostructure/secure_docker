# Class: secure_docker
# ===========================
#
# Full description of class secure_docker here.
#
# Parameters
# ----------
#
# * `sample parameter`
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# TODO: 2.6 Configure TLS authentication for Docker daemon
# TODO: Add to notes that log_level param is removed
#
class secure_docker (
  Optional[String] $tls_verify = undef,
  Optional[String] $tls_cacert = undef,
  Optional[String] $tls_cert = undef,
  Optional[String] $tls_key = undef,
  $version                           = undef,
  $ensure                            = undef,
  $prerequired_packages              = undef,
  $docker_cs                         = undef,
  $tcp_bind                          = undef,
  $tls_enable                        = undef,
  $ip_forward                        = undef,
  $ip_masq                           = undef,
  $bip                               = undef,
  $mtu                               = undef,
  $socket_bind                       = undef,
  $fixed_cidr                        = undef,
  $bridge                            = undef,
  $default_gateway                   = undef,
  $log_driver                        = undef,
  $log_opt                           = undef,
  $selinux_enabled                   = undef,
  $use_upstream_package_source       = undef,
  $package_source_location           = undef,
  $package_release                   = undef,
  $package_repos                     = undef,
  $package_key                       = undef,
  $package_key_source                = undef,
  $service_state                     = undef,
  $service_enable                    = undef,
  $manage_service                    = undef,
  $root_dir                          = undef,
  $tmp_dir                           = undef,
  $manage_kernel                     = undef,
  $dns                               = undef,
  $dns_search                        = undef,
  $socket_group                      = undef,
  $labels                            = undef,
  Array $extra_parameters            = [],
  $shell_values                      = undef,
  $proxy                             = undef,
  $no_proxy                          = undef,
  $storage_driver                    = undef,
  $dm_basesize                       = undef,
  $dm_fs                             = undef,
  $dm_mkfsarg                        = undef,
  $dm_mountopt                       = undef,
  $dm_blocksize                      = undef,
  $dm_loopdatasize                   = undef,
  $dm_loopmetadatasize               = undef,
  $dm_datadev                        = undef,
  $dm_metadatadev                    = undef,
  $dm_thinpooldev                    = undef,
  $dm_use_deferred_removal           = undef,
  $dm_use_deferred_deletion          = undef,
  $dm_blkdiscard                     = undef,
  $dm_override_udev_sync_check       = undef,
  $execdriver                        = undef,
  $manage_package                    = undef,
  $package_source                    = undef,
  $manage_epel                       = undef,
  $package_name                      = undef,
  $service_name                      = undef,
  $docker_command                    = undef,
  $daemon_subcommand                 = undef,
  $docker_users                      = undef,
  $repo_opt                          = undef,
  $nowarn_kernel                     = undef,
  $storage_devs                      = undef,
  $storage_vg                        = undef,
  $storage_root_size                 = undef,
  $storage_data_size                 = undef,
  $storage_min_data_size             = undef,
  $storage_chunk_size                = undef,
  $storage_growpart                  = undef,
  $storage_auto_extend_pool          = undef,
  $storage_pool_autoextend_threshold = undef,
  $storage_pool_autoextend_percent   = undef,
  $storage_config                    = undef,
  $storage_config_template           = undef,
  $service_provider                  = undef,
  $service_config                    = undef,
  $service_config_template           = undef,
  $service_overrides_template        = undef,
  $service_hasstatus                 = undef,
  $service_hasrestart                = undef,
  ) {

  # Docker audit roles path
  $docker_auditd_path = '/etc/audit/rules.d/docker.rules'

  class { '::secure_docker::install': } ->
  class { '::secure_docker::config': } ~>
  class { '::secure_docker::service_auditd': } ->
  Class['::secure_docker']


  Class['::secure_docker::config'] ~>
  Class['::docker::service']
}
