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

      context 'with interfaces defined' do
        let :params do
          {
            interfaces: {
              'wg0' => {
                'private_key' => 'gFYpkdIuGG3EhXKdGmuMJs/3rp/88wkFv2Go+shtu08=',
                'manage_firewall' => false,
                'destination_addresses' => [facts[:networking]['ip'],],
                'dport' => 51_820,
                'addresses' => [{ 'Address' => '192.168.218.87/24' }],
                'peers' => [{ 'public_key' => '4X0AW5W+oZQ1uP44Y2W1rv4REKjfvUt1D25weWyqryQ=', 'allowed_ips' => ['192.168.218.89/32'] }]
              },
            },
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('wireguard') }
        it { is_expected.to contain_file('/etc/wireguard') }
        it { is_expected.to contain_package('wireguard-tools') }
        it { is_expected.to contain_wireguard__interface('wg0').with(params[:interfaces]['wg0']) }
      end
    end
  end
end
