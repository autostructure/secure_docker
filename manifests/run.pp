# Calls the docker run command
# Adds checks to make sure the docker environment is hardened
# 5.9 Do not share the host's network namespace
# 5.10 Limit memory usage for container
define secure_docker::run (
  String $image,
  Pattern[/[1-9]\d*[bkmg]/] $memory_limit,
  Optional[String] $ensure = undef,
  Optional[String] $command = undef,
  Optional[Array] $cpuset = undef,
  Optional[Array] $ports = [],
  Optional[Array] $labels = undef,
  Optional[Array] $expose = undef,
  Optional[Array] $volumes = [],
  Optional[Array] $links = undef,
  Optional[Boolean] $use_name = undef,
  Optional[Boolean] $running = undef,
  Optional[Array] $volumes_from = undef,
  Optional[Pattern[/^(bridge|none|container:.+)$/]] $net = undef,
  Optional[Boolean] $username = undef,
  Optional[Boolean] $hostname = undef,
  Optional[Array] $env = undef,
  Optional[Array] $env_file = undef,
  Optional[Array] $dns = undef,
  Optional[Array] $dns_search = undef,
  Optional[Array] $lxc_conf = undef,
  Optional[String] $service_prefix = undef,
  Optional[Boolean] $restart_service = undef,
  Optional[Boolean] $restart_service_on_docker_refresh = undef,
  Optional[Boolean] $manage_service = undef,
  Optional[Boolean] $docker_service = undef,
  Optional[Boolean] $disable_network = undef,
  Optional[Boolean] $detach = undef,
  Optional[Array] $extra_parameters = [],
  Optional[Hash] $extra_systemd_parameters = undef,
  Optional[Boolean] $pull_on_start = undef,
  Optional[Array] $after = undef,
  Optional[Array] $after_service = undef,
  Optional[Array] $depends = undef,
  Optional[Array] $depend_services = undef,
  Optional[Boolean] $tty = undef,
  Optional[Array] $socket_connect = undef,
  Optional[Array] $hostentries = undef,
  Optional[Boolean] $before_start = undef,
  Optional[Boolean] $before_stop = undef,
  Optional[Boolean] $remove_container_on_start = undef,
  Optional[Boolean] $remove_container_on_stop = undef,
  Optional[Boolean] $remove_volume_on_start = undef,
  Optional[Boolean] $remove_volume_on_stop = undef,
  Optional[Boolean] $allow_additional_capabilities = false,
  Optional[Boolean] $allow_additional_privileges = false,
) {
  # 5.5 Do not mount sensitive host system directories on containers
  # $check_sensitive_mounts = grep($volumes, '^\s*\/:|\/boot:|\/dev:|\/etc:|\/lib:|\/proc:|\/sys:|\/usr:')

  if /^\s*(\/|\/boot|\/dev|\/etc|\/lib|\/proc|\/sys|\/usr):/ in $volumes {
    fail('Security concern -- /, /boot, /dev, /etc, /lib, /proc, /sys, and /usr host directories cannot be mounted.')
  }

  $cap_opt = $allow_additional_capabilities ? {
    true    => undef,
    default => '--cap-drop=all',
  }

  $security_opt = $allow_additional_privileges ? {
    true    => undef,
    default => '--security-opt=no-new-privileges',
  }

  # 5.3 Restrict Linux Kernel Capabilities within containers
  # 5.12 Mount container's root filesystem as read only
  # 5.25 Restrict container from acquiring additional privileges
  $_extra_parameters = union($extra_parameters, delete_undef_values(['--read-only', $security_opt, $cap_opt]))

  $ip_regex = '((([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5]):)'
  $port_regex = '(102[4-9]|10[3-9]\d|1[1-9]\d{2}|[2-9]\d{3}|[1-5]\d{4}|6[0-4]\d{3}|65[0-4]\d{2}|655[0-2]\d|6553[0-5])'

  # 5.7 Do not map privileged ports within containers
  # 5.13 Bind incoming container traffic to a specific host interface
  $_check_port_mappings = grep($ports, "^${ip_regex}?${port_regex}:${port_regex}(\\/udp)?$")

  if size($_check_port_mappings) != size($ports) {
    $port_differences = difference($ports, $_check_port_mappings)
    fail("Security concern -- Ports must be in the form of [<ipaddress>:]<host port>:<<container port>>[/udp]. ${port_differences}")
  }

  # 5.15 Do not share the host's process namespace
  if /--pid=host/ in $extra_parameters {
    fail('Security concern -- Containers cannot run pid=host')
  }

  # 5.16 Do not share the host's IPC namespace
  if /--ipc=host/ in $extra_parameters {
    fail('Security concern -- Containers cannot run ipc=host')
  }

  # 5.17 Do not directly expose host devices to containers
  if /--device/ in $extra_parameters {
    fail('Security concern -- Containers cannot map devices.')
  }

  # 5.19 Do not set mount propagation mode to shared
  if /.+:shared/ in $volumes {
    fail('Security concern -- Do not set mount propagation mode to shared.')
  }

  # 5.20 Do not share the host's UTS namespace
  if /--uts=host/ in $extra_parameters {
    fail('Security concern -- Containers cannot run uts=host')
  }

  # 5.21 Do not disable default seccomp profile
  if /--security-opt=(?!no-new-privileges)/ in $extra_parameters {
    fail('Security concern -- Containers cannot run security-opt')
  }

  # 5.31 Do not mount the Docker socket inside any containers
  if /docker.sock/ in $volumes {
    fail('Security concern -- Do not mount the Docker socket inside any containers.')
  }

  # 5.4 Do not use privileged containers
  # TODO: 5.14 Set the 'on-failure' container restart policy to 5
  ::docker::run { $name:
    ensure                            => $ensure,
    image                             => $image,
    command                           => $command,
    memory_limit                      => $memory_limit,
    cpuset                            => $cpuset,
    ports                             => $ports,
    labels                            => $labels,
    expose                            => $expose,
    volumes                           => $volumes,
    links                             => $links,
    use_name                          => $use_name,
    running                           => $running,
    volumes_from                      => $volumes_from,
    net                               => $net,
    username                          => $username,
    hostname                          => $hostname,
    env                               => $env,
    env_file                          => $env_file,
    dns                               => $dns,
    dns_search                        => $dns_search,
    lxc_conf                          => $lxc_conf,
    service_prefix                    => $service_prefix,
    restart_service                   => $restart_service,
    restart_service_on_docker_refresh => $restart_service_on_docker_refresh,
    manage_service                    => $manage_service,
    docker_service                    => $docker_service,
    disable_network                   => $disable_network,
    privileged                        => false,
    detach                            => $detach,
    extra_parameters                  => $_extra_parameters,
    extra_systemd_parameters          => $extra_systemd_parameters,
    pull_on_start                     => $pull_on_start,
    after                             => $after,
    after_service                     => $after_service,
    depends                           => $depends,
    depend_services                   => $depend_services,
    tty                               => $tty,
    socket_connect                    => $socket_connect,
    hostentries                       => $hostentries,
    restart                           => undef,
    before_start                      => $before_start,
    before_stop                       => $before_stop,
    remove_container_on_start         => $remove_container_on_start,
    remove_container_on_stop          => $remove_container_on_stop,
    remove_volume_on_start            => $remove_volume_on_start,
    remove_volume_on_stop             => $remove_volume_on_stop,
  }
}
