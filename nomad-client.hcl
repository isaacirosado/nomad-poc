log_level = "DEBUG"
enable_syslog = true
data_dir = "/opt/nomad"
datacenter = "${dc}"
region = "${dc}"
bind_addr = "${addr}"
client {
  enabled = true
  host_network "private" {
   interface = "eth1"
  }
  host_network "public" {
   interface = "eth0"
  }
}
consul {
  address = "127.0.0.1:8500"
}
plugin "containerd-driver" {
  config {
    enabled = true
    containerd_runtime = "io.containerd.runc.v2"
    stats_interval = "5s"
  }
}
