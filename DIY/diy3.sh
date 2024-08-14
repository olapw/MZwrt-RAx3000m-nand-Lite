#!/bin/bash


cat <<EOL >> package/base-files/files/etc/sysctl.conf

# Defaults are configured in /etc/sysctl.d/* and can be customized in this file
vm.swappiness=10
vm.vfs_cache_pressure=50

fs.nr_open=1200000
fs.file-max=200000

# Enable TCP SYN cookies
net.ipv4.tcp_syncookies=1

# Increase the maximum number of connections in the backlog
net.core.somaxconn=65535

# Increase the maximum number of queued packets
net.core.netdev_max_backlog=1000

# Increase buffer sizes for TCP
net.core.rmem_default=65536
net.core.wmem_default=65536
net.core.rmem_max=16777216
net.core.wmem_max=16777216

# TCP settings
net.ipv4.tcp_max_syn_backlog=4096
net.ipv4.tcp_synack_retries=1
net.ipv4.tcp_keepalive_time=1800
net.ipv4.tcp_keepalive_intvl=15
net.ipv4.tcp_keepalive_probes=5
net.ipv4.tcp_fin_timeout=10
net.ipv4.tcp_max_orphans=65536
net.ipv4.tcp_mem=50576 64768 98152
net.ipv4.tcp_rmem=4096 87380 16777216
net.ipv4.tcp_wmem=4096 65536 16777216
net.ipv4.tcp_orphan_retries=0
net.ipv4.tcp_no_metrics_save=1
net.ipv4.tcp_window_scaling=1
net.ipv4.tcp_timestamps=1
net.ipv4.tcp_sack=1
net.ipv4.tcp_rfc1337=1
EOL

# 清空 /etc/rc.local 文件
> /etc/rc.local

# 添加脚本
cat <<EOL >> /etc/rc.local
# Put your custom commands here that should be executed once
# the system init finished. By default this file does nothing.
#!/bin/sh

# 设置每个支持的接口的 RX 和 TX 队列大小
for iface in br-lan eth0 eth1 rax0 ra0; do
  # 配置 RX 队列
  if [ -d /sys/class/net/$iface/queues/rx-0 ]; then
    # 设置 rps_flow_cnt
    if [ -f /sys/class/net/$iface/queues/rx-0/rps_flow_cnt ]; then
      echo 1024 > /sys/class/net/$iface/queues/rx-0/rps_flow_cnt
    fi
  fi

  # 配置 TX 队列
  if [ -d /sys/class/net/$iface/queues/tx-0 ]; then
    # 设置 byte_queue_limits
    if [ -d /sys/class/net/$iface/queues/tx-0/byte_queue_limits ]; then
      echo 1024 > /sys/class/net/$iface/queues/tx-0/byte_queue_limits/limit
      echo 2048 > /sys/class/net/$iface/queues/tx-0/byte_queue_limits/limit_max
      echo 512 > /sys/class/net/$iface/queues/tx-0/byte_queue_limits/limit_min
    fi
  fi
done

exit 0
EOL


echo "diy3运行完成"