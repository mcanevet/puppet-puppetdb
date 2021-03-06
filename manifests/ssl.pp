# Class: puppetdb::ssl
#
# This class provides a simple way to configure SSL certificates for puppetdb,
# including the truststore and keystore.
#
# It requires the camptocamp/java module in order to work.
#
# This class is called by puppetdb::server.
# You shouldn't have to call it directly.
#
# Parameters:
#   ['ca_cert']            - The SSL CA certificate used.
#   ['ssl_cert']           - The SSL certificate for $ssl_listen_address,
#                            signed by the CA.
#   ['ssl_private_key']    - The SSL private key for $ssl_listen_address.
#                            `/etc/puppetdb/conf.d`.
#   ['key_password']       - The password to use for the keystore.
#   ['trust_password']     - The password to use for the truststore.
#   ['ssl_generate_key']   - Whether to generate the key.
#                            You should use this only if your puppetdb machine
#                            is also your CA machine.
#
# Actions:
# - Creates and manages the truststore/keystore for a puppetdb server
#
# Requires:
# - `camptocamp/java`
# - `camptocamp/puppet`
#
# Sample Usage:
#     class { 'puppetdb::ssl':
#         ssl_cert        => '/root/pub.pem',
#         ssl_private_key => '/root/priv.pem',
#     }
class puppetdb::ssl (
  $puppet_ssldir           = $puppetdb::params::puppet_ssldir,
  $ca_cert                 = "${puppet_ssldir}/certs/ca.pem",
  $ssl_cert                = "${puppet_ssldir}/certs/${ssl_listen_address}.pem",
  $ssl_private_key         = "${puppet_ssldir}/private_keys/${ssl_listen_address}.pem",
  $ssl_listen_address      = $puppetdb::params::ssl_listen_address,
  $ca_cert                 = $puppetdb::params::ca_cert,
  $key_password            = $puppetdb::params::key_password,
  $trust_password          = $puppetdb::params::trust_password,
  $ssl_generate_key        = true,
) inherits puppetdb::params {

  if $ssl_generate_key {
    ::puppet::cert {$ssl_listen_address:
      before => Java_ks["${ssl_listen_address}:/etc/puppetdb/ssl/keystore.jks"],
    }
  }

  java_ks { 'Puppetmaster_CA:/etc/puppetdb/ssl/truststore.jks':
    ensure      => latest,
    certificate => $ca_cert,
    password    => $trust_password,
  }

  java_ks { "${ssl_listen_address}:/etc/puppetdb/ssl/keystore.jks":
    ensure      => latest,
    certificate => $ssl_cert,
    private_key => $ssl_private_key,
    password    => $key_password,
  }

  file {[
    '/etc/puppetdb/ssl/truststore.jks',
    '/etc/puppetdb/ssl/keystore.jks',
    ]:
      owner => 'puppetdb',
      group => 'puppetdb',
  }
}
