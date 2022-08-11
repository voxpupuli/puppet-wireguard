# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'wireguard' do
  context 'with defaults' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        'include wireguard'
      end
    end
  end

  context 'with wg-quick' do
    let :facts do
      facts
    end

    it 'work with no errors' do
      pp = <<-EOS
         wireguard::interface { 'tun0':
           manage_firewall       => false,
           dport                 => 51820,
           destination_addresses => [$facts['networking']['ip']],
           addresses             => [{'Address' => '192.0.2.1/24'}],
           provider              => 'wgquick',
           peers                 => [
             {
               public_key  => 'hZC2VwCilfF9k9nQC6a86xOBFKaqdAgy123dkA6Z008=',
               allowed_ips => ['192.0.2.3'],
             }
           ],
         }

         wireguard::interface { 'tun1':
           manage_firewall       => false,
           dport                 => 51821,
           destination_addresses => [$facts['networking']['ip']],
           addresses             => [{'Address' => '192.0.3.1/24'}],
           provider              => 'wgquick',
           peers                 => [
             {
               public_key  => 'hZC2VwCilfF9k9nQC6a86xOBFKaqdAgy123dkA6Z008=',
               allowed_ips => ['192.0.3.3'],
             }
           ],
         }
      EOS

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end
  end
end
