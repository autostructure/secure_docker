
#
class secure_docker::service_auditd {
  service { 'auditd':
    ensure  => running,
    restart => '/sbin/service auditd restart',
  }
}
