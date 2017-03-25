# == Class secure_docker::config
#
# This class is called from secure_docker for service config.
#
class secure_docker::config {
  # Defaults for file_line
  $file_line_auditd_defaults = {
    path    => $::secure_docker::docker_auditd_path,
  }

  # 1.7 Audit docker daemon
  # 1.8 Audit Docker files and directories - /var/lib/docker
  # 1.9 Audit Docker files and directories - /etc/docker
  # 1.10 Audit Docker files and directories - docker-registry.service
  # 1.11 Audit Docker files and directories - /var/run/docker.sock
  # 1.12 Audit Docker files and directories - /etc/sysconfig/docker
  # 1.13 Audit Docker files and directories - /etc/docker/daemon.json
  # 1.14 Audit Docker files and directories - /usr/bin/docker-containerd
  # 1.15 Audit Docker files and directories - /usr/bin/docker-runc
  file_line {
    default:
      * => $file_line_auditd_defaults,;

    'docker_daemon_audit':
      line => '-w /usr/bin/docker -k docker',;

    'docker_var_files_audit':
      line => '-w /var/lib/docker -k docker',;

    'docker_etc_files_audit':
      line => '-w /etc/docker -k docker',;

    'docker_registry_service_audit':
      line => '-w /usr/lib/systemd/system/docker.service -k docker',;

    'docker_sock_audit':
      line => '-w /usr/lib/systemd/system/docker.socket -k docker',;

    'docker_sysconfig_audit':
      line => '-w /etc/default/docker -k docker',;

    'docker_daemon_json_audit':
      line => '-w /etc/docker/daemon.json -k docker',;

    'docker_containerd_audit':
      line => '-w /usr/bin/docker-containerd -k docker',;

    'docker_runc_audit':
      line => '-w /usr/bin/docker-runc -k docker',;
  }

  # 3.5 Verify that /etc/docker directory ownership is set to root:root
  # 3.6 Verify that /etc/docker directory permissions are set to 755 or more restrictive
  file { '/etc/docker':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => 'go-w',
  }

  # 3.7 Verify that registry certificate file ownership is set to root:root
  # 3.8 Verify that registry certificate file permissions are set to 444 or more restrictive
  file { '/etc/docker/certs.d':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    recurse => true,
    mode    => 'a-rx',
  }

  # # 3.9 Verify that TLS CA certificate file ownership is set to root:root
  # # 3.10 Verify that TLS CA certificate file permissions are set to 444 or more restrictive
  # file { $::secure_docker::tls_cacert:
  #   ensure => file,
  #   owner  => 'root',
  #   group  => 'root',
  #   mode   => '0444',
  # }

  # # 3.11 Verify that Docker server certificate file ownership is set to root:root
  # # 3.12 Verify that Docker server certificate file permissions are set to 444 or more restrictive
  # file { $::secure_docker::tls_cert:
  #   ensure => file,
  #   owner  => 'root',
  #   group  => 'root',
  #   mode   => '0444',
  # }

  # # 3.13 Verify that Docker server certificate key file ownership is set to root:root
  # # 3.14 Verify that Docker server certificate key file permissions are set to 400
  # file { $::secure_docker::tls_key:
  #   ensure => file,
  #   owner  => 'root',
  #   group  => 'root',
  #   mode   => '0400',
  # }

  # 3.15 Verify that Docker socket file ownership is set to root:docker
  # 3.16 Verify that Docker socket file permissions are set to 660 or more restrictive
  file { '/var/run/docker.sock':
    owner => 'root',
    group => 'docker',
    mode  => 'a-x,o-rwx',
  }

  # daemon.json is incompatiable with the current Puppet module
  # 3.17 Verify that daemon.json file ownership is set to root:root
  # 3.18 Verify that daemon.json file permissions are set to 644 or more restrictive
  file { '/etc/docker/daemon.json':
    ensure => absent,
    owner  => 'root',
    group  => 'root',
    mode   => 'a-x,go-w',
  }

  # 3.19 Verify that /etc/default/docker file ownership is set to root:root
  # 3.20 Verify that /etc/default/docker file permissions are set to 644 or more restrictive
  file { '/etc/default/docker':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => 'a-x,go-w',
  }
}
