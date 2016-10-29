require 'spec_helper'

describe 'selinux' do
  include_context 'RedHat 7'

  context 'config' do
    context 'invalid type' do
      let(:params) { { type: 'invalid' } }
      it { expect { is_expected.to create_class('selinux') }.to raise_error(%r{Valid types are targeted, minimum, and mls.  Received: invalid}) }
    end

    context 'undef type' do
      it { is_expected.to have_file_resource_count(1) }
      it { is_expected.to have_file_line_resource_count(0) }
      it { is_expected.to have_exec_resource_count(0) }

      it { is_expected.to contain_file('/usr/share/selinux') }
      it { is_expected.not_to contain_file_line('set-selinux-config-type-to-targeted') }
      it { is_expected.not_to contain_file_line('set-selinux-config-type-to-minimum') }
      it { is_expected.not_to contain_file_line('set-selinux-config-type-to-mls') }
    end

    context 'targeted' do
      let(:params) { { type: 'targeted' } }

      it { is_expected.to contain_file('/usr/share/selinux').with(ensure: 'directory') }
      it { is_expected.to contain_file_line('set-selinux-config-type-to-targeted').with(line: 'SELINUXTYPE=targeted') }
    end

    context 'minimum' do
      let(:params) { { type: 'minimum' } }

      it { is_expected.to contain_file('/usr/share/selinux').with(ensure: 'directory') }
      it { is_expected.to contain_file_line('set-selinux-config-type-to-minimum').with(line: 'SELINUXTYPE=minimum') }
    end

    context 'mls' do
      let(:params) { { type: 'mls' } }

      it { is_expected.to contain_file('/usr/share/selinux').with(ensure: 'directory') }
      it { is_expected.to contain_file_line('set-selinux-config-type-to-mls').with(line: 'SELINUXTYPE=mls') }
    end
  end
end
