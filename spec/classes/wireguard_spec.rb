# frozen_string_literal: true

require 'spec_helper'

describe 'wireguard' do
  let :node do
    'postgres01.example.com'
  end

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let :facts do
        facts
      end

      context 'with all defaults' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_file('/etc/wireguard') }
        it { is_expected.to contain_package('wireguard-tools') }
      end
    end
  end
end
