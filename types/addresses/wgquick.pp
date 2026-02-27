# @summary custom data type for addresses used for wgquick provider
#
type Wireguard::Addresses::Wgquick = Array[Struct[{
    'Address' => Variant[Stdlib::IP::Address::V4,Stdlib::IP::Address::V6],
    'Peer' => Optional[Variant[Stdlib::IP::Address::V4,Stdlib::IP::Address::V6]],
    'DNS' => Optional[Variant[Stdlib::IP::Address::V4,Stdlib::IP::Address::V6]],
  }]
]
