require 'spec_helper'

describe 'secure_docker' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context "secure_docker class without any parameters" do
          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('secure_docker') }
          it { is_expected.to contain_class('secure_docker::install').that_comes_before('Class[secure_docker::config]') }
          it { is_expected.to contain_class('secure_docker::config').that_notifies('Class[secure_docker::service_auditd]') }
          it { is_expected.to contain_class('secure_docker::service_auditd').that_comes_before('Class[secure_docker]') }

          it {
            is_expected.to contain_file('/etc/audit/rules.d/docker.rules').with( 'ensure' => 'file')
          }

          it {
            is_expected.to contain_file('/etc/default/docker').with(
              'ensure' => 'file',
              'owner'  => 'root',
              'group'  => 'root',
              'mode'   => 'a-x,go-w'
            )
          }

          it {
            is_expected.to contain_file('/etc/docker/certs.d').with(
              'ensure'  => 'directory',
              'owner'   => 'root',
              'group'   => 'root',
              'recurse' => true,
              'mode'    => 'a-rx'
            )
          }

          it {
            is_expected.to contain_file('/etc/docker/daemon.json').with(
              'ensure' => 'absent',
              'owner'  => 'root',
              'group'  => 'root',
              'mode'   => 'a-x,go-w'
            )
          }

          it {
            is_expected.to contain_file('/etc/docker').with(
              'ensure' => 'directory',
              'owner'  => 'root',
              'group'  => 'root',
              'mode'   => 'go-w'
            )
          }

          it {
            is_expected.to contain_file('/var/run/docker.sock').with(
              'ensure' => 'file',
              'owner'  => 'root',
              'group'  => 'docker',
              'mode'   => 'a-x,o-rwx'
            )
          }

          it {
            is_expected.to contain_file_line('docker_containerd_audit').with(
              'path' => '/etc/audit/rules.d/docker.rules',
              'line' => '-w /usr/bin/docker-containerd -k docker'
            )
          }

          it {
            is_expected.to contain_file_line('docker_daemon_audit').with(
              'path' => '/etc/audit/rules.d/docker.rules'
            )
          }

          it {
            is_expected.to contain_file_line('docker_daemon_json_audit').with(
              'path' => '/etc/audit/rules.d/docker.rules',
              'line' => '-w /etc/docker/daemon.json -k docker'
            )
          }

          it {
            is_expected.to contain_file_line('docker_etc_files_audit').with(
              'path' => '/etc/audit/rules.d/docker.rules',
              'line' => '-w /etc/docker -k docker'
            )
          }

          it {
            is_expected.to contain_file_line('docker_registry_service_audit').with(
              'path' => '/etc/audit/rules.d/docker.rules',
              'line' => '-w /usr/lib/systemd/system/docker.service -k docker'
            )
          }

          it {
            is_expected.to contain_file_line('docker_runc_audit').with(
              'path' => '/etc/audit/rules.d/docker.rules',
              'line' => '-w /usr/bin/docker-runc -k docker'
            )
          }

          it {
            is_expected.to contain_file_line('docker_sock_audit').with(
              'path' => '/etc/audit/rules.d/docker.rules',
              'line' => '-w /usr/lib/systemd/system/docker.socket -k docker'
            )
          }

          it {
            is_expected.to contain_file_line('docker_sysconfig_audit').with(
              'path' => '/etc/audit/rules.d/docker.rules',
              'line' => '-w /etc/default/docker -k docker'
            )
          }

          it {
            is_expected.to contain_file_line('docker_var_files_audit').with(
              'path' => '/etc/audit/rules.d/docker.rules',
              'line' => '-w /var/lib/docker -k docker'
            )
          }

          it {
            is_expected.to contain_service('auditd').with(
              'ensure'  => 'running',
              'restart' => '/sbin/service auditd restart'
            )
          }
        end
      end
    end
  end
end
