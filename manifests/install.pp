# @summary Manage the installation of the crypto policy package(s)
#
# @param packages
#   The list of packages to manage for this capability
#
# @param package_ensure
#   The 'ensure' parameter for `$packages`
#
#   * NOTE: There are issues with `crypto-policies < 20190000` which may render
#     a FIPS system inaccessible.
#
# @author https://github.com/simp/pupmod-simp-crypto_policy/graphs/contributors
#
class crypto_policy::install (
  Array[String[1]] $packages       = ['crypto-policies', 'crypto-policies-scripts'],
  String[1]        $package_ensure = 'latest'
) {
  assert_private()

  package { $packages: ensure => $package_ensure }
}
