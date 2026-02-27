# @summary custom data type for addresses
#
# This data type is allowed for all interface provider.
# For settings not available in all providers, use the
# the specific datatype.
# Settings added here, needs also be setup in
# Wireguard::Addresses::*.
#
type Wireguard::Addresses = Array[Struct[{
    'Address' => Variant[Stdlib::IP::Address::V4,Stdlib::IP::Address::V6],
    'Peer' => Optional[Variant[Stdlib::IP::Address::V4,Stdlib::IP::Address::V6]],
    'DNS' => Optional[Variant[Stdlib::IP::Address::V4,Stdlib::IP::Address::V6]],
  }]
]
