# frozen_string_literal: true

require 'spec_helper'

describe 'Wireguard::Addresses' do
  describe 'valid types' do
    context 'with valid types' do
      [
        [],
        [{ 'Address' => '1.1.1.1/32' }, { 'Address' => '::1/128', 'DNS' => '42.42.42.42' }],
        [{ 'Address' => '1.1.1.1', 'Peer' => '2.2.2.2' }, { 'Address' => '::1' }],
      ].each do |value|
        describe value.inspect do
          it { is_expected.to allow_value(value) }
        end
      end
    end
  end

  describe 'invalid types' do
    context 'with garbage inputs' do
      [
        true,
        false,
        :keyword,
        nil,
        { 'foo' => 'bar' },
        {},
        '55555',
      ].each do |value|
        describe value.inspect do
          it { is_expected.not_to allow_value(value) }
        end
      end
    end
  end
end
