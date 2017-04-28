# =>=> Class secure_docker::install
#
# This class is called from secure_docker for install.
#
class secure_docker::install {

  # 2.x TODO: SCRUB incoming extra_parameters

  # 2.1 Restrict network traffic between containers
  # 2.3 Allow Docker to make changes to iptables
  # 2.13 Disable operations on legacy registry (v1)
  # 2.14 Enable live restore
  # 2.18 Disable Userland Proxy
  # TODO: 2.4 Do not use insecure registries
  $dockerd_params = [
    '--icc=false',
    '--iptables=true',
    '--disable-legacy-registry',
    '--live-restore',
    '--userland-proxy=false',
  ]

  $extra_parameters_dirty = concat($::secure_docker::extra_parameters, $dockerd_params)

  # TODO: 2.5 Do not use the aufs storage driver
  # $extra_parameters_clean = delete_regex($extra_parameters_dirty, '--storage-driver\s+aufs')

  # 2.2 Set the logging level
  class { '::docker':
    version                           => $::secure_docker::version,
    ensure                            => $::secure_docker::ensure,
    prerequired_packages              => $::secure_docker::prerequired_packages,
    docker_cs                         => $::secure_docker::docker_cs,
    tcp_bind                          => $::secure_docker::tcp_bind,
    tls_enable                        => $::secure_docker::tls_enable,
    tls_verify                        => $::secure_docker::tls_verify,
    tls_cacert                        => $::secure_docker::tls_cacert,
    tls_cert                          => $::secure_docker::tls_cert,
    tls_key                           => $::secure_docker::tls_key,
    ip_forward                        => $::secure_docker::ip_forward,
    ip_masq                           => $::secure_docker::ip_masq,
    bip                               => $::secure_docker::bip,
    mtu                               => $::secure_docker::mtu,
    iptables                          => true,
    socket_bind                       => $::secure_docker::socket_bind,
    fixed_cidr                        => $::secure_docker::fixed_cidr,
    bridge                            => $::secure_docker::bridge,
    default_gateway                   => $::secure_docker::default_gateway,
    log_level                         => 'info',
    log_driver                        => $::secure_docker::log_driver,
    log_opt                           => $::secure_docker::log_opt,
    selinux_enabled                   => $::secure_docker::selinux_enabled,
    use_upstream_package_source       => $::secure_docker::use_upstream_package_source,
    package_source_location           => $::secure_docker::package_source_location,
    package_release                   => $::secure_docker::package_release,
    package_repos                     => $::secure_docker::package_repos,
    package_key                       => $::secure_docker::package_key,
    package_key_source                => $::secure_docker::package_key_source,
    service_state                     => $::secure_docker::service_state,
    service_enable                    => $::secure_docker::service_enable,
    manage_service                    => $::secure_docker::manage_service,
    root_dir                          => $::secure_docker::root_dir,
    tmp_dir                           => $::secure_docker::tmp_dir,
    manage_kernel                     => $::secure_docker::manage_kernel,
    dns                               => $::secure_docker::dns,
    dns_search                        => $::secure_docker::dns_search,
    socket_group                      => $::secure_docker::socket_group,
    labels                            => $::secure_docker::labels,
    extra_parameters                  => $extra_parameters_dirty,
    shell_values                      => $::secure_docker::shell_values,
    proxy                             => $::secure_docker::proxy,
    no_proxy                          => $::secure_docker::no_proxy,
    storage_driver                    => $::secure_docker::storage_driver,
    dm_basesize                       => $::secure_docker::dm_basesize,
    dm_fs                             => $::secure_docker::dm_fs,
    dm_mkfsarg                        => $::secure_docker::dm_mkfsarg,
    dm_mountopt                       => $::secure_docker::dm_mountopt,
    dm_blocksize                      => $::secure_docker::dm_blocksize,
    dm_loopdatasize                   => $::secure_docker::dm_loopdatasize,
    dm_loopmetadatasize               => $::secure_docker::dm_loopmetadatasize,
    dm_datadev                        => $::secure_docker::dm_datadev,
    dm_metadatadev                    => $::secure_docker::dm_metadatadev,
    dm_thinpooldev                    => $::secure_docker::dm_thinpooldev,
    dm_use_deferred_removal           => $::secure_docker::dm_use_deferred_removal,
    dm_use_deferred_deletion          => $::secure_docker::dm_use_deferred_deletion,
    dm_blkdiscard                     => $::secure_docker::dm_blkdiscard,
    dm_override_udev_sync_check       => $::secure_docker::dm_override_udev_sync_check,
    execdriver                        => $::secure_docker::execdriver,
    manage_package                    => $::secure_docker::manage_package,
    package_source                    => $::secure_docker::package_source,
    manage_epel                       => $::secure_docker::manage_epel,
    package_name                      => $::secure_docker::package_name,
    service_name                      => $::secure_docker::service_name,
    docker_command                    => $::secure_docker::docker_command,
    daemon_subcommand                 => $::secure_docker::daemon_subcommand,
    docker_users                      => $::secure_docker::docker_users,
    repo_opt                          => $::secure_docker::repo_opt,
    nowarn_kernel                     => $::secure_docker::nowarn_kernel,
    storage_devs                      => $::secure_docker::storage_devs,
    storage_vg                        => $::secure_docker::storage_vg,
    storage_root_size                 => $::secure_docker::storage_root_size,
    storage_data_size                 => $::secure_docker::storage_data_size,
    storage_min_data_size             => $::secure_docker::storage_min_data_size,
    storage_chunk_size                => $::secure_docker::storage_chunk_size,
    storage_growpart                  => $::secure_docker::storage_growpart,
    storage_auto_extend_pool          => $::secure_docker::storage_auto_extend_pool,
    storage_pool_autoextend_threshold => $::secure_docker::storage_pool_autoextend_threshold,
    storage_pool_autoextend_percent   => $::secure_docker::storage_pool_autoextend_percent,
    storage_config                    => $::secure_docker::storage_config,
    storage_config_template           => $::secure_docker::storage_config_template,
    service_provider                  => $::secure_docker::service_provider,
    service_config                    => $::secure_docker::service_config,
    service_config_template           => $::secure_docker::service_config_template,
    service_overrides_template        => $::secure_docker::service_overrides_template,
    service_hasstatus                 => $::secure_docker::service_hasstatus,
  }

  # Make sure docker rules exists
  file { $::secure_docker::docker_auditd_path:
    ensure => file,
  }

  # Make sure group docker exists
  group { 'docker': }
}
