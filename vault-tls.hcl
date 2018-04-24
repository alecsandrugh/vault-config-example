storage "consul" {
  address = "127.0.0.1:8500"
  path    = "vault/"
}
listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_cert_file = "/etc/ssl/vault/vault.crt"
  tls_key_file = "/etc/ssl/vault/vault.key"
}
ui=true
