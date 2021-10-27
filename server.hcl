server {
  enabled = true
  bootstrap_expect = ${count}
  server_join {
    retry_join = ${servers}
  }
}
