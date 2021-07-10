require 'spec_helper'

describe 'wireguard::interface', type: :define do
  let(:title) { 'as1234' }

  on_supported_os.each do |os, facts|
    context "on #{os} " do
      let :facts do
        facts
      end

      context 'with all defaults it wont work' do
        it { is_expected.not_to compile }
      end
      context 'with required params and without firewall rules' do
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
        it { is_expected.to contain_exec("generate #{title} keys") }
        it { is_expected.to contain_file("/etc/wireguard/#{title}.pub") }
        it { is_expected.to contain_file("/etc/wireguard/#{title}") }
        it { is_expected.to contain_systemd__network("#{title}.netdev") }
        it { is_expected.to contain_systemd__network("#{title}.network") }
        it { is_expected.to contain_file("/etc/systemd/network/#{title}.netdev").with_content(%r{Name=#{title}}) }
        it { is_expected.to contain_file("/etc/systemd/network/#{title}.netdev").with_content(%r{PrivateKeyFile=/etc/wireguard/#{title}}) }
        it { is_expected.to contain_file("/etc/systemd/network/#{title}.netdev").with_content(%r{ListenPort=1234}) }
        it { is_expected.to contain_file("/etc/systemd/network/#{title}.netdev").with_content(%r{Endpoint=#{params[:endpoint]}}) }
        it { is_expected.to contain_file("/etc/systemd/network/#{title}.network").without_content(%r{Address}) }
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
        it { is_expected.to contain_exec("generate #{title} keys") }
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
        it { is_expected.to contain_exec("generate #{title} keys") }
        it { is_expected.to contain_file("/etc/wireguard/#{title}.pub") }
        it { is_expected.to contain_file("/etc/wireguard/#{title}") }
        it { is_expected.to contain_systemd__network("#{title}.netdev") }
        it { is_expected.to contain_systemd__network("#{title}.network") }
        it { is_expected.to contain_file("/etc/systemd/network/#{title}.network").with_content(%r{[Address]}) }
        it { is_expected.to contain_file("/etc/systemd/network/#{title}.network").with_content(%r{Address=192.168.218.87/32}) }
        it { is_expected.to contain_file("/etc/systemd/network/#{title}.network").with_content(%r{Peer=172.20.53.97/32}) }
        it { is_expected.to contain_file("/etc/systemd/network/#{title}.network").with_content(%r{Address=fe80::ade1/64}) }
        it { is_expected.not_to contain_ferm__rule("allow_wg_#{title}") }
      end
    end
  end
end
