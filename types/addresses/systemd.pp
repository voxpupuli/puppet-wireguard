# @summary custom data type for addresses used for the systemd provider
#
type Wireguard::Addresses::Systemd = Array[Struct[{
    'Address' => Variant[Stdlib::IP::Address::V4,Stdlib::IP::Address::V6],
    'Peer' => Optional[Variant[Stdlib::IP::Address::V4,Stdlib::IP::Address::V6]],
    'DNS' => Optional[Variant[Stdlib::IP::Address::V4,Stdlib::IP::Address::V6]],
    # systemd specific values
    'RouteMetric' => Optional[Integer[0,4294967295]],
  }]
]
