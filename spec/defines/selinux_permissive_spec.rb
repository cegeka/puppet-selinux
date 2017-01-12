require 'spec_helper'

describe 'selinux::permissive' do
  let(:title) { 'mycontextp' }
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      context 'context allow-oddjob_mkhomedir_t to permissive' do
        let(:params) do
          {
            context: 'oddjob_mkhomedir_t'
          }
        end
        it do
          is_expected.to contain_exec('add_oddjob_mkhomedir_t').with(command: 'semanage permissive -a oddjob_mkhomedir_t')
          is_expected.to contain_selinux__permissive('mycontextp').that_requires('Anchor[selinux::module post]')
          is_expected.to contain_selinux__permissive('mycontextp').that_comes_before('Anchor[selinux::end]')
        end
      end
    end
  end
end
