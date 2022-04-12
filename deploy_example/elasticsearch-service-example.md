
#### service scripte 예시
```yml
#vi  /usr/lib/systemd/system/elasticsearch.service

[Unit]
Description=Elasticsearch
Wants=network-online.target
After=network-online.target
[Service]
Environment=ES_HOME=/data/elasticsearch-cluster/elasticsearch-7.13.1
Environment=CONF_DIR=/data/elasticsearch-cluster/elasticsearch-7.13.1/config
Environment=DATA_DIR=/data/elasticsearch-cluster/elasticsearch-7.13.1/data
Environment=LOG_DIR=/data/elasticsearch-cluster/elasticsearch-7.13.1/logs
Environment=PID_DIR=/data/elasticsearch-cluster/elasticsearch-7.13.1/
EnvironmentFile=-/data/elasticsearch-cluster/elasticsearch-7.13.1/config
WorkingDirectory=/data/elasticsearch-cluster/elasticsearch-7.13.1/
User=elastic
Group=elastic
ExecStart=/data/elasticsearch-cluster/elasticsearch-7.13.1/bin/elasticsearch \
-p ${PID_DIR}/elasticsearch.pid \
--quiet

# StandardOutput is configured to redirect to journalctl since
# some error messages may be logged in standard output before
# elasticsearch logging system is initialized. Elasticsearch
# stores its logs in /var/log/elasticsearch and does not use
# journalctl by default. If you also want to enable journalctl
# logging, you can simply remove the "quiet" option from ExecStart.
StandardOutput=journal
StandardError=inherit
# Specifies the maximum file descriptor number that can be opened by this process
LimitNOFILE=65536

# Specifies the maximum size of virtual memory
LimitAS=infinity

# Specifies the maximum file size
LimitFSIZE=infinity

# Specifies the maximum number of bytes of memory that may be locked into RAM
# Set to "infinity" if you use the 'bootstrap.memory_lock: true' option
# in elasticsearch.yml and 'MAX_LOCKED_MEMORY=unlimited' in /etc/sysconfig/elasticsearch
LimitMEMLOCK=infinity
# Disable timeout logic and wait until process is stopped
TimeoutStopSec=0
# SIGTERM signal is used to stop the Java process
KillSignal=SIGTERM

# Send the signal only to the JVM rather than its control group
KillMode=process

# Java process is never killed
SendSIGKILL=no
# When a JVM receives a SIGTERM signal it exits with code 143
SuccessExitStatus=143

# Allow a slow startup before the systemd notifier module kicks in to extend the timeout
TimeoutStartSec=75

[Install]
WantedBy=multi-user.target
# Built for distribution-7.13.0 (distribution)
```
#### yum install 시 생성되는 버전
```yml
[Unit]
Description=Elasticsearch
Documentation=https://www.elastic.co
Wants=network-online.target
After=network-online.target

[Service]
Type=notify
RuntimeDirectory=elasticsearch
PrivateTmp=true
Environment=ES_HOME=/data/elasticsearch_cluster/elasticsearch-7.13.1
Environment=ES_PATH_CONF=/data/elasticsearch_cluster/elasticsearch-7.13.1/config
Environment=PID_DIR=/data/elasticsearch_cluster/elasticsearch-7.13.1
Environment=ES_SD_NOTIFY=true
EnvironmentFile=-/etc/sysconfig/elasticsearch

WorkingDirectory=/usr/share/elasticsearch

User=elasticsearch
Group=elasticsearch

ExecStart=/usr/share/elasticsearch/bin/systemd-entrypoint -p ${PID_DIR}/elasticsearch.pid --quiet

# StandardOutput is configured to redirect to journalctl since
# some error messages may be logged in standard output before
# elasticsearch logging system is initialized. Elasticsearch
# stores its logs in /var/log/elasticsearch and does not use
# journalctl by default. If you also want to enable journalctl
# logging, you can simply remove the "quiet" option from ExecStart.
StandardOutput=journal
StandardError=inherit

# Specifies the maximum file descriptor number that can be opened by this process
LimitNOFILE=65535

# Specifies the maximum number of processes
LimitNPROC=4096

# Specifies the maximum size of virtual memory
LimitAS=infinity

# Specifies the maximum file size
LimitFSIZE=infinity

# Disable timeout logic and wait until process is stopped
TimeoutStopSec=0

# SIGTERM signal is used to stop the Java process
KillSignal=SIGTERM

# Send the signal only to the JVM rather than its control group
KillMode=process

# Java process is never killed
SendSIGKILL=no

# When a JVM receives a SIGTERM signal it exits with code 143
SuccessExitStatus=143

# Allow a slow startup before the systemd notifier module kicks in to extend the timeout
TimeoutStartSec=75

[Install]
WantedBy=multi-user.target

# Built for packages-7.13.2 (packages)

```
