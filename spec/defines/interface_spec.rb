# frozen_string_literal: true

require 'spec_helper'

describe 'wireguard::interface', type: :define do
  let(:title) { 'as1234' }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let :facts do
        facts
      end

      context 'with all defaults it wont work' do
        it { is_expected.not_to compile }
      end

      context 'with required params (public_key) and without firewall rules' do
        let :params do
          {
            public_key: 'blabla==',
            endpoint: 'wireguard.example.com:1234',
            manage_firewall: false,
            # we need to set destination_addresses to overwrite the default
            # that would configure IPv4+IPv6, but GHA doesn't provide IPv6 for us
            destination_addresses: [facts[:networking]['ip'],],
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('wireguard') }
        it { is_expected.to contain_exec("generate private key #{title}") }
        it { is_expected.to contain_exec("generate public key #{title}") }
        it { is_expected.to contain_file("/etc/wireguard/#{title}.pub") }
        it { is_expected.to contain_file("/etc/wireguard/#{title}") }
        it { is_expected.to contain_systemd__network("#{title}.netdev") }
        it { is_expected.to contain_systemd__network("#{title}.network") }
        it { is_expected.to contain_file("/etc/systemd/network/#{title}.netdev").with_content(%r{Name=#{title}}) }
        it { is_expected.to contain_file("/etc/systemd/network/#{title}.netdev").with_content(%r{PrivateKeyFile=/etc/wireguard/#{title}}) }
        it { is_expected.to contain_file("/etc/systemd/network/#{title}.netdev").with_content(%r{ListenPort=1234}) }
        it { is_expected.to contain_file("/etc/systemd/network/#{title}.netdev").with_content(%r{Endpoint=#{params[:endpoint]}}) }
        it { is_expected.to contain_file("/etc/systemd/network/#{title}.netdev").with_content(%r{PersistentKeepalive=0}) }
        it { is_expected.to contain_file("/etc/systemd/network/#{title}.network").without_content(%r{Address}) }
        it { is_expected.to contain_file("/etc/systemd/network/#{title}.network").without_content(%r{Description}) }
        it { is_expected.to contain_file("/etc/systemd/network/#{title}.network").without_content(%r{MTUBytes}) }
        it { is_expected.not_to contain_ferm__rule("allow_wg_#{title}") }
      end

      context 'with required params (public_key) and without firewall rules and with PersistentKeepalive=5' do
        let :params do
          {
            public_key: 'blabla==',
            endpoint: 'wireguard.example.com:1234',
            manage_firewall: false,
            persistent_keepalive: 5,
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_file("/etc/systemd/network/#{title}.netdev").with_content(%r{PersistentKeepalive=5}) }
      end

      context 'with required params (peers) and without firewall rules' do
        let :params do
          {
            peers: [
              {
                public_key: 'blabla==',
                endpoint: 'wireguard.example.com:1234',
              },
              {
                public_key: 'foo==',
                preshared_key: 'bar=',
                description: 'foo',
                allowed_ips: ['192.0.2.3'],
              }
            ],
            manage_firewall: false,
            # we need to set destination_addresses to overwrite the default
            # that would configure IPv4+IPv6, but GHA doesn't provide IPv6 for us
            destination_addresses: [facts[:networking]['ip'],],
            addresses: [{ 'Address' => '192.0.2.1/24' }],
          }
        end

        let(:expected_netdev_content) do
          File.read('spec/fixtures/test_files/peers.netdev')
        end

        let(:expected_network_content) do
          File.read('spec/fixtures/test_files/peers.network')
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('wireguard') }
        it { is_expected.to contain_exec("generate private key #{title}") }
        it { is_expected.to contain_exec("generate public key #{title}") }
        it { is_expected.to contain_file("/etc/wireguard/#{title}.pub") }
        it { is_expected.to contain_file("/etc/wireguard/#{title}") }
        it { is_expected.to contain_systemd__network("#{title}.netdev") }
        it { is_expected.to contain_systemd__network("#{title}.network") }
        it { is_expected.to contain_file("/etc/systemd/network/#{title}.netdev").with_content(expected_netdev_content) }
        it { is_expected.to contain_file("/etc/systemd/network/#{title}.network").with_content(expected_network_content) }
        it { is_expected.not_to contain_ferm__rule("allow_wg_#{title}") }
      end

      context 'with required params and with firewall rules' do
        # we need to set configfile/configdirectory because the ferm module doesn't provide defaults for all OSes we test against
        let :pre_condition do
          'class{"ferm":
          configfile => "/etc/ferm.conf",
          configdirectory => "/etc/ferm.d/"
          }
          class {"systemd":
            manage_networkd => true
          }'
        end
        let :params do
          {
            public_key: 'blabla==',
            endpoint: 'wireguard.example.com:1234',
            # we need to set destination_addresses to overwrite the default
            # that would configure IPv4+IPv6, but GHA doesn't provide IPv6 for us
            destination_addresses: [facts[:networking]['ip'],],
            source_addresses: ['127.0.0.1'],
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('wireguard') }
        it { is_expected.to contain_exec("generate private key #{title}") }
        it { is_expected.to contain_exec("generate public key #{title}") }
        it { is_expected.to contain_file("/etc/wireguard/#{title}.pub") }
        it { is_expected.to contain_file("/etc/wireguard/#{title}") }
        it { is_expected.to contain_systemd__network("#{title}.netdev") }
        it { is_expected.to contain_systemd__network("#{title}.network") }
        it { is_expected.to contain_file("/etc/systemd/network/#{title}.network").without_content(%r{Address}) }
        it { is_expected.to contain_ferm__rule("allow_wg_#{title}") }
      end

      context 'with required params and without firewall rules and with configured addresses' do
        let :params do
          {
            public_key: 'blabla==',
            endpoint: 'wireguard.example.com:1234',
            manage_firewall: false,
            # we need to set destination_addresses to overwrite the default
            # that would configure IPv4+IPv6, but GHA doesn't provide IPv6 for us
            destination_addresses: [facts[:networking]['ip'],],
            addresses: [{ 'Address' => '192.168.218.87/32', 'Peer' => '172.20.53.97/32' }, { 'Address' => 'fe80::ade1/64', },],
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('wireguard') }
        it { is_expected.to contain_exec("generate private key #{title}") }
        it { is_expected.to contain_exec("generate public key #{title}") }
        it { is_expected.to contain_file("/etc/wireguard/#{title}.pub") }
        it { is_expected.to contain_file("/etc/wireguard/#{title}") }
        it { is_expected.to contain_systemd__network("#{title}.netdev") }
        it { is_expected.to contain_systemd__network("#{title}.network") }
        it { is_expected.to contain_file("/etc/systemd/network/#{title}.network").with_content(%r{[Address]}) } # rubocop:disable Lint/DuplicateRegexpCharacterClassElement
        it { is_expected.to contain_file("/etc/systemd/network/#{title}.network").with_content(%r{Address=192.168.218.87/32}) }
        it { is_expected.to contain_file("/etc/systemd/network/#{title}.network").with_content(%r{Peer=172.20.53.97/32}) }
        it { is_expected.to contain_file("/etc/systemd/network/#{title}.network").with_content(%r{Address=fe80::ade1/64}) }
        it { is_expected.not_to contain_ferm__rule("allow_wg_#{title}") }
      end

      context 'with empty destintion_addresses' do
        let :pre_condition do
          'class{"ferm":
          configfile => "/etc/ferm.conf",
          configdirectory => "/etc/ferm.d/"
          }
          class {"systemd":
            manage_networkd => true
          }'
        end
        let :params do
          {
            public_key: 'blabla==',
            endpoint: 'wireguard.example.com:1234',
            manage_firewall: true,
            destination_addresses: [],
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_ferm__rule("allow_wg_#{title}").without_daddr }
      end

      context 'with description' do
        let :params do
          {
            public_key: 'blabla==',
            endpoint: 'wireguard.example.com:1234',
            manage_firewall: false,
            description: 'bla',
            # we need to set destination_addresses to overwrite the default
            # that would configure IPv4+IPv6, but GHA doesn't provide IPv6 for us
            destination_addresses: [facts[:networking]['ip'],],
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_file("/etc/systemd/network/#{title}.netdev").with_content(%r{Description=bla}) }
      end

      context 'with MTU' do
        let :params do
          {
            public_key: 'blabla==',
            endpoint: 'wireguard.example.com:1234',
            manage_firewall: false,
            mtu: 9000,
            # we need to set destination_addresses to overwrite the default
            # that would configure IPv4+IPv6, but GHA doesn't provide IPv6 for us
            destination_addresses: [facts[:networking]['ip'],],
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_file("/etc/systemd/network/#{title}.netdev").with_content(%r{MTUBytes=9000}) }
      end

      context 'with too high MTU' do
        let :params do
          {
            public_key: 'blabla==',
            endpoint: 'wireguard.example.com:1234',
            manage_firewall: false,
            mtu: 9001,
            # we need to set destination_addresses to overwrite the default
            # that would configure IPv4+IPv6, but GHA doesn't provide IPv6 for us
            destination_addresses: [facts[:networking]['ip'],],
          }
        end

        it { is_expected.not_to compile.with_all_deps }
      end

      context 'with MTU as string' do
        let :params do
          {
            public_key: 'blabla==',
            endpoint: 'wireguard.example.com:1234',
            manage_firewall: false,
            mtu: '9000',
            # we need to set destination_addresses to overwrite the default
            # that would configure IPv4+IPv6, but GHA doesn't provide IPv6 for us
            destination_addresses: [facts[:networking]['ip'],],
          }
        end

        it { is_expected.not_to compile.with_all_deps }
      end

      context 'with required params (peers), routes and without firewall rules' do
        let :params do
          {
            peers: [
              {
                public_key: 'blabla==',
                endpoint: 'wireguard.example.com:1234',
              },
              {
                public_key: 'foo==',
                preshared_key: 'bar=',
                description: 'foo',
                allowed_ips: ['192.0.2.3'],
              }
            ],
            manage_firewall: false,
            # we need to set destination_addresses to overwrite the default
            # that would configure IPv4+IPv6, but GHA doesn't provide IPv6 for us
            destination_addresses: [facts[:networking]['ip'],],
            addresses: [{ 'Address' => '192.0.2.1/24' }],
            routes: [{ 'Gateway' => '192.0.2.2', 'GatewayOnLink' => true, 'Destination' => '192.0.3.0/24' }],
          }
        end

        let(:expected_netdev_content) do
          File.read('spec/fixtures/test_files/peers.netdev')
        end

        let(:expected_network_content) do
          File.read('spec/fixtures/test_files/peers_routes.network')
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('wireguard') }
        it { is_expected.to contain_exec("generate private key #{title}") }
        it { is_expected.to contain_exec("generate public key #{title}") }
        it { is_expected.to contain_file("/etc/wireguard/#{title}.pub") }
        it { is_expected.to contain_file("/etc/wireguard/#{title}") }
        it { is_expected.to contain_systemd__network("#{title}.netdev") }
        it { is_expected.to contain_systemd__network("#{title}.network") }
        it { is_expected.to contain_file("/etc/systemd/network/#{title}.netdev").with_content(expected_netdev_content) }
        it { is_expected.to contain_file("/etc/systemd/network/#{title}.network").with_content(expected_network_content) }
        it { is_expected.not_to contain_ferm__rule("allow_wg_#{title}") }
      end

      context 'with required params and defined private key and without firewall rules and with configured addresses' do
        let :params do
          {
            public_key: 'blabla==',
            private_key: 'gFYpkdIuGG3EhXKdGmuMJs/3rp/88wkFv2Go+shtu08=',
            endpoint: 'wireguard.example.com:1234',
            manage_firewall: false,
            # we need to set destination_addresses to overwrite the default
            # that would configure IPv4+IPv6, but GHA doesn't provide IPv6 for us
            destination_addresses: [facts[:networking]['ip'],],
            addresses: [{ 'Address' => '192.168.218.87/32', 'Peer' => '172.20.53.97/32' }, { 'Address' => 'fe80::ade1/64', },],
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('wireguard') }
        it { is_expected.not_to contain_exec("generate private key #{title}") }
        it { is_expected.to contain_file("/etc/wireguard/#{title}").with_content('gFYpkdIuGG3EhXKdGmuMJs/3rp/88wkFv2Go+shtu08=') }
        it { is_expected.to contain_exec("generate public key #{title}") }
        it { is_expected.to contain_file("/etc/wireguard/#{title}.pub") }
        it { is_expected.to contain_systemd__network("#{title}.netdev") }
        it { is_expected.to contain_systemd__network("#{title}.network") }
        it { is_expected.to contain_file("/etc/systemd/network/#{title}.network").with_content(%r{[Address]}) } # rubocop:disable Lint/DuplicateRegexpCharacterClassElement
        it { is_expected.to contain_file("/etc/systemd/network/#{title}.network").with_content(%r{Address=192.168.218.87/32}) }
        it { is_expected.to contain_file("/etc/systemd/network/#{title}.network").with_content(%r{Peer=172.20.53.97/32}) }
        it { is_expected.to contain_file("/etc/systemd/network/#{title}.network").with_content(%r{Address=fe80::ade1/64}) }
        it { is_expected.not_to contain_ferm__rule("allow_wg_#{title}") }
      end

      context 'wgquick with required params (public_key) and without firewall rules' do
        let :params do
          {
            public_key: 'blabla==',
            endpoint: 'wireguard.example.com:1234',
            manage_firewall: false,
            # we need to set destination_addresses to overwrite the default
            # that would configure IPv4+IPv6, but GHA doesn't provide IPv6 for us
            destination_addresses: [facts[:networking]['ip'],],
            provider: 'wgquick',
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('wireguard') }
        it { is_expected.to contain_exec("generate private key #{title}") }
        it { is_expected.to contain_exec("generate public key #{title}") }
        it { is_expected.to contain_file("/etc/wireguard/#{title}.pub") }
        it { is_expected.to contain_file("/etc/wireguard/#{title}") }
        it { is_expected.to contain_file("/etc/wireguard/#{title}.conf") }
        it { is_expected.not_to contain_ferm__rule("allow_wg_#{title}") }
      end

      context 'with required params and defined private key and without firewall rules and with configured addresses with dns' do
        let :params do
          {
            public_key: 'blabla==',
            private_key: 'gFYpkdIuGG3EhXKdGmuMJs/3rp/88wkFv2Go+shtu08=',
            endpoint: 'wireguard.example.com:1234',
            manage_firewall: false,
            # we need to set destination_addresses to overwrite the default
            # that would configure IPv4+IPv6, but GHA doesn't provide IPv6 for us
            destination_addresses: [facts[:networking]['ip'],],
            addresses: [{ 'Address' => '192.168.218.87/32', 'DNS' => '192.168.218.1', 'Peer' => '172.20.53.97/32' }, { 'Address' => 'fe80::ade1/64', },],
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('wireguard') }
        it { is_expected.not_to contain_exec("generate private key #{title}") }
        it { is_expected.to contain_file("/etc/wireguard/#{title}").with_content('gFYpkdIuGG3EhXKdGmuMJs/3rp/88wkFv2Go+shtu08=') }
        it { is_expected.to contain_exec("generate public key #{title}") }
        it { is_expected.to contain_file("/etc/wireguard/#{title}.pub") }
        it { is_expected.to contain_systemd__network("#{title}.netdev") }
        it { is_expected.to contain_systemd__network("#{title}.network") }
        it { is_expected.to contain_file("/etc/systemd/network/#{title}.network").with_content(%r{[Address]}) } # rubocop:disable Lint/DuplicateRegexpCharacterClassElement
        it { is_expected.to contain_file("/etc/systemd/network/#{title}.network").with_content(%r{Address=192.168.218.87/32}) }
        it { is_expected.to contain_file("/etc/systemd/network/#{title}.network").with_content(%r{DNS=192.168.218.1}) }
        it { is_expected.to contain_file("/etc/systemd/network/#{title}.network").with_content(%r{Peer=172.20.53.97/32}) }
        it { is_expected.to contain_file("/etc/systemd/network/#{title}.network").with_content(%r{Address=fe80::ade1/64}) }
        it { is_expected.not_to contain_ferm__rule("allow_wg_#{title}") }
      end

      context 'wgquick with required params (public_key) and an address entry with dns also without firewall rules' do
        let :params do
          {
            public_key: 'blabla==',
            endpoint: 'wireguard.example.com:1234',
            manage_firewall: false,
            destination_addresses: [facts[:networking]['ip'],],
            provider: 'wgquick',
            addresses: [{ 'Address' => '192.168.218.87/32', 'DNS' => '192.168.218.1' }],
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('wireguard') }
        it { is_expected.to contain_exec("generate private key #{title}") }
        it { is_expected.to contain_exec("generate public key #{title}") }
        it { is_expected.to contain_file("/etc/wireguard/#{title}.pub") }
        it { is_expected.to contain_file("/etc/wireguard/#{title}") }
        it { is_expected.to contain_file("/etc/wireguard/#{title}.conf") }
        it { is_expected.to contain_file("/etc/wireguard/#{title}.conf").with_content(%r{[Interface]}) } # rubocop:disable Lint/DuplicateRegexpCharacterClassElement
        it { is_expected.to contain_file("/etc/wireguard/#{title}.conf").with_content(%r{Address=192.168.218.87/32}) }
        it { is_expected.to contain_file("/etc/wireguard/#{title}.conf").with_content(%r{DNS=192.168.218.1}) }
        it { is_expected.not_to contain_ferm__rule("allow_wg_#{title}") }
      end

      context 'wgquick with postup and predown commands and without firewall' do
        let :params do
          {
            public_key: 'blabla==',
            endpoint: 'wireguard.example.com:1234',
            manage_firewall: false,
            destination_addresses: [facts[:networking]['ip'],],
            provider: 'wgquick',
            addresses: [{ 'Address' => '192.168.218.87/32' }],
            postup_cmds: [
              'resolvectl dns %i 10.34.3.1; resolvectl domain %i "~hello"',
            ],
            predown_cmds: [
              'resolvectl revert %i',
            ],
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('wireguard') }
        it { is_expected.to contain_exec("generate private key #{title}") }
        it { is_expected.to contain_exec("generate public key #{title}") }
        it { is_expected.to contain_file("/etc/wireguard/#{title}.pub") }
        it { is_expected.to contain_file("/etc/wireguard/#{title}") }
        it { is_expected.to contain_file("/etc/wireguard/#{title}.conf") }
        it { is_expected.to contain_file("/etc/wireguard/#{title}.conf").with_content(%r{[Interface]}) } # rubocop:disable Lint/DuplicateRegexpCharacterClassElement
        it { is_expected.to contain_file("/etc/wireguard/#{title}.conf").with_content(%r{Address=192.168.218.87/32}) }
        it { is_expected.to contain_file("/etc/wireguard/#{title}.conf").with_content(%r{PostUp=resolvectl dns %i 10.34.3.1; resolvectl domain %i "~hello"}) }
        it { is_expected.to contain_file("/etc/wireguard/#{title}.conf").with_content(%r{PreDown=resolvectl revert %i}) }
        it { is_expected.not_to contain_ferm__rule("allow_wg_#{title}") }
      end

      context 'wgquick with mtu and without firewall' do
        let :params do
          {
            public_key: 'blabla==',
            endpoint: 'wireguard.example.com:1234',
            manage_firewall: false,
            destination_addresses: [facts[:networking]['ip'],],
            provider: 'wgquick',
            addresses: [{ 'Address' => '192.168.218.87/32' }],
            mtu: 1280,
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('wireguard') }
        it { is_expected.to contain_exec("generate private key #{title}") }
        it { is_expected.to contain_exec("generate public key #{title}") }
        it { is_expected.to contain_file("/etc/wireguard/#{title}.pub") }
        it { is_expected.to contain_file("/etc/wireguard/#{title}") }
        it { is_expected.to contain_file("/etc/wireguard/#{title}.conf") }
        it { is_expected.to contain_file("/etc/wireguard/#{title}.conf").with_content(%r{[Interface]}) } # rubocop:disable Lint/DuplicateRegexpCharacterClassElement
        it { is_expected.to contain_file("/etc/wireguard/#{title}.conf").with_content(%r{Address=192.168.218.87/32}) }
        it { is_expected.to contain_file("/etc/wireguard/#{title}.conf").with_content(%r{MTU=1280}) }
        it { is_expected.not_to contain_ferm__rule("allow_wg_#{title}") }
      end

      context 'with required params and firewall mark and without firewall rules' do
        let :params do
          {
            public_key: 'blabla==',
            endpoint: 'wireguard.example.com:1234',
            firewall_mark: 1234,
            manage_firewall: false,
            description: 'bla',
            # we need to set destination_addresses to overwrite the default
            # that would configure IPv4+IPv6, but GHA doesn't provide IPv6 for us
            destination_addresses: [facts[:networking]['ip'],],
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_file("/etc/systemd/network/#{title}.netdev").with_content(%r{FirewallMark=1234}) }
      end
    end
  end
end
