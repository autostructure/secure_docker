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

          it { is_expected.to contain_class('secure_docker::install').that_comes_before('Class[secure_docker::config]') }
          it { is_expected.to contain_class('secure_docker::config') }
        end
      end
    end
  end
end
