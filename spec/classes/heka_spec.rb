require 'spec_helper'

describe 'heka' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context "heka class without any parameters" do
          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('heka::params') }
          it { is_expected.to contain_class('heka::install').that_comes_before('heka::config') }
          it { is_expected.to contain_class('heka::config') }
          it { is_expected.to contain_class('heka::service').that_subscribes_to('heka::config') }

          it { is_expected.to contain_service('heka') }
          it { is_expected.to contain_package('heka').with_ensure('installed') }
        end
      end
    end
  end

  context 'unsupported operating system' do
    describe 'heka class without any parameters on Solaris/Nexenta' do
      let(:facts) do
        {
          :osfamily        => 'Solaris',
          :operatingsystem => 'Nexenta',
        }
      end

      it { expect { is_expected.to contain_package('heka') }.to raise_error(Puppet::Error, /Nexenta not supported/) }
    end
  end
end
