# Changelog

All notable changes to this project will be documented in this file.
Each new release typically also includes the latest modulesync defaults.
These should not affect the functionality of the module.

## [v2.1.0](https://github.com/voxpupuli/puppet-wireguard/tree/v2.1.0) (2022-10-01)

[Full Changelog](https://github.com/voxpupuli/puppet-wireguard/compare/v2.0.4...v2.1.0)

**Implemented enhancements:**

- Add pre/post up/down commands for wgquick [\#66](https://github.com/voxpupuli/puppet-wireguard/pull/66) ([sebastianrakel](https://github.com/sebastianrakel))

## [v2.0.4](https://github.com/voxpupuli/puppet-wireguard/tree/v2.0.4) (2022-08-22)

[Full Changelog](https://github.com/voxpupuli/puppet-wireguard/compare/v2.0.3...v2.0.4)

**Fixed bugs:**

- Fix wgquick template and extend tests [\#64](https://github.com/voxpupuli/puppet-wireguard/pull/64) ([sebastianrakel](https://github.com/sebastianrakel))

## [v2.0.3](https://github.com/voxpupuli/puppet-wireguard/tree/v2.0.3) (2022-08-22)

[Full Changelog](https://github.com/voxpupuli/puppet-wireguard/compare/v2.0.2...v2.0.3)

**Fixed bugs:**

- Fix $addresses hash needs to accept any type of v4 or v6 address [\#61](https://github.com/voxpupuli/puppet-wireguard/pull/61) ([sebastianrakel](https://github.com/sebastianrakel))

## [v2.0.2](https://github.com/voxpupuli/puppet-wireguard/tree/v2.0.2) (2022-08-17)

[Full Changelog](https://github.com/voxpupuli/puppet-wireguard/compare/v2.0.1...v2.0.2)

**Fixed bugs:**

- Workaround for missing ipv6 addresses [\#59](https://github.com/voxpupuli/puppet-wireguard/pull/59) ([bastelfreak](https://github.com/bastelfreak))

## [v2.0.1](https://github.com/voxpupuli/puppet-wireguard/tree/v2.0.1) (2022-08-15)

[Full Changelog](https://github.com/voxpupuli/puppet-wireguard/compare/v2.0.0...v2.0.1)

**Fixed bugs:**

- \(\#52\) Fix dependency cycle [\#53](https://github.com/voxpupuli/puppet-wireguard/pull/53) ([silug](https://github.com/silug))

**Closed issues:**

- Setting wireguard::interaces causes a dependency cycle [\#52](https://github.com/voxpupuli/puppet-wireguard/issues/52)

**Merged pull requests:**

- Release 2.0.0 [\#57](https://github.com/voxpupuli/puppet-wireguard/pull/57) ([sebastianrakel](https://github.com/sebastianrakel))

## [v2.0.0](https://github.com/voxpupuli/puppet-wireguard/tree/v2.0.0) (2022-08-14)

[Full Changelog](https://github.com/voxpupuli/puppet-wireguard/compare/v1.1.0...v2.0.0)

**Breaking changes:**

- Move preshared\_key from interface to peer configuration [\#51](https://github.com/voxpupuli/puppet-wireguard/pull/51) ([hashworks](https://github.com/hashworks))

**Implemented enhancements:**

- Add wg quick as another provider for interfaces [\#54](https://github.com/voxpupuli/puppet-wireguard/pull/54) ([sebastianrakel](https://github.com/sebastianrakel))

**Fixed bugs:**

- Throw warning instead of fail if peers is empty  [\#55](https://github.com/voxpupuli/puppet-wireguard/pull/55) ([sebastianrakel](https://github.com/sebastianrakel))

## [v1.1.0](https://github.com/voxpupuli/puppet-wireguard/tree/v1.1.0) (2022-08-03)

[Full Changelog](https://github.com/voxpupuli/puppet-wireguard/compare/v1.0.0...v1.1.0)

**Implemented enhancements:**

- Allow usage of pre-shared keys on interfaces [\#49](https://github.com/voxpupuli/puppet-wireguard/pull/49) ([Southparkfan](https://github.com/Southparkfan))

**Merged pull requests:**

- Enable basic acceptance tests [\#48](https://github.com/voxpupuli/puppet-wireguard/pull/48) ([bastelfreak](https://github.com/bastelfreak))

## [v1.0.0](https://github.com/voxpupuli/puppet-wireguard/tree/v1.0.0) (2022-03-11)

[Full Changelog](https://github.com/voxpupuli/puppet-wireguard/compare/v0.10.0...v1.0.0)

**Implemented enhancements:**

- Create private\_key from parameter if wanted [\#43](https://github.com/voxpupuli/puppet-wireguard/pull/43) ([sebastianrakel](https://github.com/sebastianrakel))

**Merged pull requests:**

- Minor grammar corrections [\#41](https://github.com/voxpupuli/puppet-wireguard/pull/41) ([hashworks](https://github.com/hashworks))
- Provide hiera integration [\#35](https://github.com/voxpupuli/puppet-wireguard/pull/35) ([bahner](https://github.com/bahner))

## [v0.10.0](https://github.com/voxpupuli/puppet-wireguard/tree/v0.10.0) (2021-12-10)

[Full Changelog](https://github.com/voxpupuli/puppet-wireguard/compare/v0.9.0...v0.10.0)

**Implemented enhancements:**

- Add description to peers [\#38](https://github.com/voxpupuli/puppet-wireguard/pull/38) ([sebastianrakel](https://github.com/sebastianrakel))
- Add possibility to define routes [\#36](https://github.com/voxpupuli/puppet-wireguard/pull/36) ([sebastianrakel](https://github.com/sebastianrakel))

## [v0.9.0](https://github.com/voxpupuli/puppet-wireguard/tree/v0.9.0) (2021-09-17)

[Full Changelog](https://github.com/voxpupuli/puppet-wireguard/compare/v0.8.2...v0.9.0)

**Implemented enhancements:**

- Add possibility to add multiple peers [\#31](https://github.com/voxpupuli/puppet-wireguard/pull/31) ([sebastianrakel](https://github.com/sebastianrakel))

## [v0.8.2](https://github.com/voxpupuli/puppet-wireguard/tree/v0.8.2) (2021-08-26)

[Full Changelog](https://github.com/voxpupuli/puppet-wireguard/compare/v0.8.1...v0.8.2)

the V0.8.1 release had an issue in the Rakefile which prevented the release. V0.8.2 fixes only this and is otherwise identical to the v0.8.1 release.

**Fixed bugs:**

- remove gettext workaround from Rakefile [\#28](https://github.com/voxpupuli/puppet-wireguard/pull/28) ([bastelfreak](https://github.com/bastelfreak))

## [v0.8.1](https://github.com/voxpupuli/puppet-wireguard/tree/v0.8.1) (2021-08-26)

[Full Changelog](https://github.com/voxpupuli/puppet-wireguard/compare/v0.8.0...v0.8.1)

**Merged pull requests:**

- Allow stdlib 8.0.0 [\#26](https://github.com/voxpupuli/puppet-wireguard/pull/26) ([smortex](https://github.com/smortex))

## [v0.8.0](https://github.com/voxpupuli/puppet-wireguard/tree/v0.8.0) (2021-08-21)

[Full Changelog](https://github.com/voxpupuli/puppet-wireguard/compare/v0.7.0...v0.8.0)

**Implemented enhancements:**

- Implement `mtu` param to configure MTUBytes [\#23](https://github.com/voxpupuli/puppet-wireguard/pull/23) ([bastelfreak](https://github.com/bastelfreak))

**Fixed bugs:**

- fact: support keyfiles with multiple dots [\#24](https://github.com/voxpupuli/puppet-wireguard/pull/24) ([bastelfreak](https://github.com/bastelfreak))

## [v0.7.0](https://github.com/voxpupuli/puppet-wireguard/tree/v0.7.0) (2021-08-19)

[Full Changelog](https://github.com/voxpupuli/puppet-wireguard/compare/v0.6.2...v0.7.0)

**Implemented enhancements:**

- add option to purge unknown wg keys [\#21](https://github.com/voxpupuli/puppet-wireguard/pull/21) ([bastelfreak](https://github.com/bastelfreak))
- Add fact to export public keys [\#19](https://github.com/voxpupuli/puppet-wireguard/pull/19) ([bastelfreak](https://github.com/bastelfreak))
- Implement description attribute for network interface [\#18](https://github.com/voxpupuli/puppet-wireguard/pull/18) ([bastelfreak](https://github.com/bastelfreak))

## [v0.6.2](https://github.com/voxpupuli/puppet-wireguard/tree/v0.6.2) (2021-08-02)

[Full Changelog](https://github.com/voxpupuli/puppet-wireguard/compare/v0.6.1...v0.6.2)

**Fixed bugs:**

- Make filtering on dest addr optional [\#16](https://github.com/voxpupuli/puppet-wireguard/pull/16) ([bastelfreak](https://github.com/bastelfreak))

## [v0.6.1](https://github.com/voxpupuli/puppet-wireguard/tree/v0.6.1) (2021-07-30)

[Full Changelog](https://github.com/voxpupuli/puppet-wireguard/compare/v0.6.0...v0.6.1)

the 0.6.0 release wasn't successful because the CI pipeline failed. 0.6.1 contains the same Puppet code + a fixed Gemfile



## [v0.6.0](https://github.com/voxpupuli/puppet-wireguard/tree/v0.6.0) (2021-07-30)

[Full Changelog](https://github.com/voxpupuli/puppet-wireguard/compare/v0.5.0...v0.6.0)

**Implemented enhancements:**

- Implement PersistentKeepalive parameter [\#12](https://github.com/voxpupuli/puppet-wireguard/pull/12) ([bastelfreak](https://github.com/bastelfreak))
- Make endpoint parameter optional [\#10](https://github.com/voxpupuli/puppet-wireguard/pull/10) ([bastelfreak](https://github.com/bastelfreak))
- wireguard:interface: default `input_interface` to `networking.primary` fact [\#9](https://github.com/voxpupuli/puppet-wireguard/pull/9) ([bastelfreak](https://github.com/bastelfreak))

**Fixed bugs:**

- dont make `$destination_addresses` as optional, remove useless validation [\#11](https://github.com/voxpupuli/puppet-wireguard/pull/11) ([bastelfreak](https://github.com/bastelfreak))
- puppet:wireguard: set default for `$source_addresses` to `[]` [\#8](https://github.com/voxpupuli/puppet-wireguard/pull/8) ([bastelfreak](https://github.com/bastelfreak))

**Merged pull requests:**

- switch from camptocamp/systemd to voxpupuli/systemd [\#6](https://github.com/voxpupuli/puppet-wireguard/pull/6) ([bastelfreak](https://github.com/bastelfreak))

## [v0.5.0](https://github.com/voxpupuli/puppet-wireguard/tree/v0.5.0) (2021-07-12)

[Full Changelog](https://github.com/voxpupuli/puppet-wireguard/compare/79faeed0d4d264d9b78b0f447e6c567b826f8ac9...v0.5.0)

**Merged pull requests:**

- Add README.md and LICENSE [\#4](https://github.com/voxpupuli/puppet-wireguard/pull/4) ([bastelfreak](https://github.com/bastelfreak))
- Add unit test for defined resource [\#3](https://github.com/voxpupuli/puppet-wireguard/pull/3) ([bastelfreak](https://github.com/bastelfreak))
- Add unit test for main class [\#2](https://github.com/voxpupuli/puppet-wireguard/pull/2) ([bastelfreak](https://github.com/bastelfreak))



\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
