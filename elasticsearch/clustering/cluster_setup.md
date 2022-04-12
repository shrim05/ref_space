# Elasticsearch Cluster 구축 Guide
##### 작성: 권영호 (mr.kwon05@gmail.com)
##### last modified: 2021.06.16
##### Elasticsearch version: 7.13
## About
- Elasticsearch Cluster 를 복수의 물리 호스트에 설정하는 방법 기록
- 기존에는 각 서비스마다 별도의 ELK(elasticsearch,logstash,Kibana) 스택을 docker container single node 형태로 활용 -> 실제 대외 서비스 운영에 활용하기 위한 기반으로 사용하기 위해 클러스터 구성 필요성 생김 (수평확장하기 위함) -> 각 물리서버 당 docker container 형태로 클러스터를 구성하기 위해선 쿠버네티스같은 컨테이너 오케스트레이션 툴이 필요 -> 현 수준에서는 learning curve 및 관리의 어려움으로 on-premise 형태로 클러스터 구성 후 추후 쿠버네티스 도입 고려
## 설치환경
- OS: CentOS Linux 8 (Core)
- JAVA 
    - openjdk version "1.8.0_262"
    - OpenJDK Runtime Environment (build 1.8.0_262-b10)
    - OpenJDK 64-Bit Server VM (build 25.262-b10, mixed mode)

### 설치과정 요약
- rpm으로 설치 시 기본으로 세팅되는 것이 많아 편하지만, 기본 폴더 위치 변경이나, 권한 등 설정이 귀찮고 한서버에 노드를 여러개 돌릴 때 번거로움
- tar파일로 설치 시 명확하지만, 직접 시스템 유저 추가 (=> 꼭 필요한 것은 아니나 추후 문제 발생 시 확인 용도 및 메모리 한계를 푸는 설정 때문에 별도로 관리하고자 함) 및 systemctl service 파일을 직접 만들어줘야함
- 여기서는 tar 파일 설치 기준으로 진행함.
1. [시스템 유저 추가(선택사항)](#system-user-add)
1. [tar파일 압축 풀기 및 설치](#tar-파일로-설치)
1. [클러스터 세팅](#기본-환경설정)
1. [OS-시스템 관련 설정](#os-시스템-환경설정)
1. [Snapshot 백업을 위한 NFS 설치](#nfs-server-setting)
1. [서비스파일 등록(선택사항)](#service-파일-예시)
1. [보안처리(선택사항)](#보안-설정)
1. [시각화 및 조회 툴 kibana 설차](#kibana-설치)
1. [system service 등록(선택사항)](#systemctl-service-등록)

### System User Add
- elasticsearch-cluster 시스템 유저 추가(선택사항)
```shell
sudo useradd elastic -u 9200
sudo usermod -aG elastic $USER
```
## Work-history
### ◆ Elasticsearch 설치
#### tar 파일로 설치
- 상세 설치 과정은 공식 홈페이지 [가이드](https://www.elastic.co/guide/en/elasticsearch/reference/7.13/targz.html)를 참조 
```shell
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.13.1-linux-x86_64.tar.gz
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.13.1-linux-x86_64.tar.gz.sha512
shasum -a 512 -c elasticsearch-7.13.1-linux-x86_64.tar.gz.sha512 
tar -xzf elasticsearch-7.13.1-linux-x86_64.tar.gz
# nori-tokenizer install
./elasticsearch-7.13.1/bin/elasticsearch-plugin install analysis-nori
# elastic 유저를 별도로 추가했을 시
sudo chown -R elastic:elastic elasticsearch-7.13.1
sudo chmod -R g+w elasticsearch-7.13.1
```
- 최신 버전 클러스터 구성 [예시](https://velog.io/@dhjung/Elasticsearch-%EC%84%A4%EC%B9%98)
- 본 문서에는 설치 과정 중 발생하는 예외 상황과 해결 방법에 대해서만 기술
#### 클러스트 개요
- 1번서버(Master Node)
- 2,3번 서버(Data Node)

#### 기본 환경설정
##### config/jvm.options
- 호스트 메모리의 50% 정도 배분 하지만 32g는 넘지않도록 설정
- 32g 제한 이유 -> Compressed OOP 사용 위해 제한 [상세설명](https://icarus8050.tistory.com/53)
- 32g로 세팅해도 운영체제나 환경에 따라 C-OOP를 사용 못하는 경우가 있으니 그냥 편하게 31 또는 30g로 세팅 추천
```yml
-Xms30g
-Xmx30g
```

##### config/elasticsearch.yml
- 클러스터 이름, 노드 이름, 로그 경로, 데이터 경로 등 설정 [설정 방법 참고](https://esbook.kimjmin.net/02-install/2.3-elasticsearch/2.3.2-elasticsearch.yml)
#### 현재 서버별 설정 값
##### 5번 서버 (코디네이터 노드)
```yml
cluster.name: euclid-elk-cluster
node.name: euclid-server5-node1
network.host: ["_local_","_site_"]
network.publish_host: "${ip_addr}"
http.port: 9200
transport.tcp.port: 9300
node.roles: []
discovery.seed_hosts: ["${ip_addr}:9300","${ip_addr}:9300","${ip_addr}:9300", "${ip_addr}:9300" ]
cluster.initial_master_nodes: ["euclid-server6-node1", euclid-server7-node1, euclid-server8-node1]
bootstrap.memory_lock: true

# 스냅샷 저장경로 => NFS 서버 장애가 생기면 모든 클라이언트에 문제 발생.. 가용성 높은 방식 탐색 필요
# path.repo: ["/data/NFS"] 

# xpack 관련 설정
xpack.security.enabled: true
xpack.security.transport.ssl.enabled: true
xpack.security.transport.ssl.verification_mode: certificate
xpack.security.transport.ssl.keystore.path: elastic-certificates.p12
xpack.security.transport.ssl.truststore.path: elastic-certificates.p12
```
##### 6 번 서버 (마스터/데이터 노드)
```yml
cluster.name: euclid-elk-cluster
node.name: euclid-server6-node1
network.host: ["_local_","_site_"]
network.publish_host: "${ip_addr}"
http.port: 9200
transport.tcp.port: 9300
node.roles: [master, data]
discovery.seed_hosts: ["${ip_addr}:9300","${ip_addr}:9300","${ip_addr}:9300", "${ip_addr}:9300" ]
cluster.initial_master_nodes: ["euclid-server6-node1", euclid-server7-node1, euclid-server8-node1]
bootstrap.memory_lock: true

# 스냅샷 저장경로
# path.repo: ["/data/NFS"]

# xpack 관련 설정
xpack.security.enabled: true
xpack.security.transport.ssl.enabled: true
xpack.security.transport.ssl.verification_mode: certificate
xpack.security.transport.ssl.keystore.path: elastic-certificates.p12
xpack.security.transport.ssl.truststore.path: elastic-certificates.p12
```
##### 7 번 서버 (마스터/데이터 노드)
```yml
cluster.name: euclid-elk-cluster
node.name: euclid-server7-node1
network.host: ["_local_","_site_"]
network.publish_host: "${ip_addr}"
http.port: 9200
transport.tcp.port: 9300
node.roles: [master, data]
discovery.seed_hosts: ["${ip_addr}:9300","${ip_addr}:9300","${ip_addr}:9300", "${ip_addr}:9300" ]
cluster.initial_master_nodes: ["euclid-server6-node1", euclid-server7-node1, euclid-server8-node1]
bootstrap.memory_lock: true

# 스냅샷 저장경로
path.repo: ["/data/NFS"]

# xpack 관련 설정
xpack.security.enabled: true
xpack.security.transport.ssl.enabled: true
xpack.security.transport.ssl.verification_mode: certificate
xpack.security.transport.ssl.keystore.path: elastic-certificates.p12
xpack.security.transport.ssl.truststore.path: elastic-certificates.p12
```
##### 8 번 서버 (마스터/데이터 노드)
```yml
cluster.name: euclid-elk-cluster
node.name: euclid-server8-node1
network.host: ["_local_","_site_"]
network.publish_host: "${ip_addr}"
http.port: 9200
transport.tcp.port: 9300
node.roles: [master, data]
discovery.seed_hosts: ["${ip_addr}:9300","${ip_addr}:9300","${ip_addr}:9300", "${ip_addr}:9300" ]
cluster.initial_master_nodes: ["euclid-server6-node1", euclid-server7-node1, euclid-server8-node1]
bootstrap.memory_lock: true

# 스냅샷 저장경로
path.repo: ["/data/NFS"]

# xpack 관련 설정
xpack.security.enabled: true
xpack.security.transport.ssl.enabled: true
xpack.security.transport.ssl.verification_mode: certificate
xpack.security.transport.ssl.keystore.path: elastic-certificates.p12
xpack.security.transport.ssl.truststore.path: elastic-certificates.p12
```

#### OS 시스템 환경설정
##### 메모리 및 파일디스크립터 제한 설정
- 리소스 제한 풀기 (ulimit 설정)
```shell
# 조회
ulimit -a
# 수정
ulimit -옵션 최대값
# 영구 적용
vi /etc/security/limits.conf

# 수정 검토 값
# open files: 생성할 수 있는 파일 디스크립터 개수, 최소 65536개 이상
계정명  -   nofile  81920
# 설정 시 오류 발생 시 -> 커널에서도 내부적으로 설정가능한 파일 개수를 넘어가면 에러. 에러 발생 시 커널 레벨에서 먼저 늘려야함
cat /proc/sys/fs/file-max

# Max Thread 한계 설정
# ulimit -a 시 max user processes 값으로 확인 가능
계정명 -   nproc   81920

# 가상 메모리 제한 풀기
계정명  -   memlock    unlimited
```
- sysctl: 커널 설정 설정 (민감한 정보이므로 수정에 주의) 
```shell
# 조회
/sbin/sysctl -a
# 수정
sysctl -w 파리미터명 = 파라미터 값
# 영구 적용
vi /etc/sysctl.conf

# 수정 검토 값
# vm.max_map_count
vm.max_map_count=262144
# 수정값 반영
sysctl -p 
```


##### 방화벽 오픈 
- 각 서버 마다 9205, 9305 포트 오픈 (기본 포트는 9200, 9300)
- 9205 오픈은 외부와 통신하는 곳만 필요
```shell
sudo firewall-cmd --permanent --zone=public --add-port=9205/tcp 
sudo firewall-cmd --permanent --zone=public --add-port=9305/tcp 
sudo firewall-cmd --reload 
sudo firewall-cmd --list-ports
```
[출처](https://msyu1207.tistory.com/entry/Elasticsearch-설치-및-외부-허용)

#### service 파일 예시
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
# Specifies the maximum number of bytes of memory that may be locked into RAM
# Set to "infinity" if you use the 'bootstrap.memory_lock: true' option
# in elasticsearch.yml and 'MAX_LOCKED_MEMORY=unlimited' in /etc/sysconfig/elasticsearch
LimitMEMLOCK=infinity
# Disable timeout logic and wait until process is stopped
TimeoutStopSec=0
# SIGTERM signal is used to stop the Java process
KillSignal=SIGTERM
# Java process is never killed
SendSIGKILL=no
# When a JVM receives a SIGTERM signal it exits with code 143
SuccessExitStatus=143
[Install]
WantedBy=multi-user.target
# Built for distribution-5.4.0 (distribution)
```

### Kibana 설치
- 기본 설치 과정은 공식 홈페이지 절차대로 수행 [공식홈페이지](https://www.elastic.co/guide/en/kibana/7.13/targz.html)
- master node 가 있는 1번 서버에만 설치 진행함
```shell
curl -O https://artifacts.elastic.co/downloads/kibana/kibana-7.13.1-linux-x86_64.tar.gz
curl https://artifacts.elastic.co/downloads/kibana/kibana-7.13.1-linux-x86_64.tar.gz.sha512 | shasum -a 512 -c - 
tar -xzf kibana-7.13.1-linux-x86_64.tar.gz
cd kibana-7.13.1-linux-x86_64/ 
```
#### kibana 설정
- $KIBANA_HOME/config/kibana.yml 수정
```yml
# 기본 포트 5601 외 포트 사용 할 경우 설정
server.port: 5605
# 외부에서 접근이 가능하도록 0.0.0.0 설정
server.host: "0.0.0.0"
# 클러스터 내 모든 마스터 노드들의 호스트 명시
elasticsearch.hosts: ["http://${ip_addr}:9205"]
# xpack 기본 인증 사용 위해서 이름 비밀번호 설정 (기본인증 서비스 6.8 이후 부터 유료->무료 전환)
elasticsearch.username: "유저이름"
elasticsearch.password: "비밀번호"
```
- 방화벽 오픈
```shell
sudo firewall-cmd --permanent --zone=public --add-port=5605/tcp 
sudo firewall-cmd --reload 
```

#### 보안 설정
- 보안개요 [참고1](https://www.elastic.co/kr/blog/how-to-prevent-elasticsearch-server-breach-securing-elasticsearch)
- 보안설정방법 [참고2](https://www.elastic.co/kr/blog/getting-started-with-elasticsearch-security)
- tls 설정에 대해 [참고3](https://www.elastic.co/kr/blog/elasticsearch-security-configure-tls-ssl-pki-authentication)

1. 보안확인
    ```
    # request
    GET _xpack/usage?filter_path=security
    # response
    { 
    "security" : { 
        "available" : true, 
        "enabled" : false, // 보안이 비활성화된 경우 “false”로 설정됨 
        "ssl" : { 
        "http" : { 
            "enabled" : false 
        }, 
        "transport" : { 
            "enabled" : false 
        } 
        } 
    } 
    }
    ```
1. 기본 보안 방법
    1. TLS 활성화
        1. 마스터 디렉터리에서 아래 명령 실행
            ```shell
            bin/elasticsearch-certutil cert -out config/elastic-certificates.p12 -pass ""
            ```
        1.  config/elasticsearch.yaml 에 보안 설정 추가
            ```yml
            xpack.security.enabled: true
            xpack.security.transport.ssl.enabled: true
            xpack.security.transport.ssl.verification_mode: certificate
            xpack.security.transport.ssl.keystore.path: elastic-certificates.p12
            xpack.security.transport.ssl.truststore.path: elastic-certificates.p12
            ```
        1. 모든 노드 서버에 위에서 생성한 elastic-certificates.p12 인증서 복사 ($ES_HOME/config/아래에복사)
        1. 모든 노드 서버에 xpack.security.* 설정 값 추가


    1. 클러스터 인증 활성화
        1. 마스터 디렉터리에서 아래 명령 실행
            ```shell
            # 각 서비스에 대한 비밀번호 수동 설정
            bin/elasticsearch-setup-passwords interactive
            ```
        1. kibana에 위에서 만든 비밀번호값 입력
            ```yml
            # config/kibana.yml
            elasticsearch.username: "user"
            elasticsearch.password: "pass"
            ```

### ◆ snapshot 설정
- 엘라스틱서치 스냅샷 관련 설정 [참고1](https://www.elastic.co/guide/en/elasticsearch/guide/current/backing-up-your-cluster.html)
- 스냅샷/복구 방법 예시 [참고2](https://jjeong.tistory.com/1276)
- CentOs8 NFS 설정방법 [참고3](https://ccambo.tistory.com/entry/CentOS-NFS-CentOS-8%EC%97%90-NFS-%EC%84%A4%EC%A0%95-%EB%B0%8F-%ED%85%8C%EC%8A%A4%ED%8A%B8)
- CentOS8 NFS 설정방법2 [참고4](https://ccambo.tistory.com/entry/CentOS-NFS-CentOS-8%EC%97%90-NFS-%EC%84%A4%EC%A0%95-%EB%B0%8F-%ED%85%8C%EC%8A%A4%ED%8A%B8)
- 여러 대의 서버로 클러스터 구성 시 스냅샷(백업기능)을 이용하기 위해서는 다른 노드 서버들이 함께 접근 가능한 파일 시스템이 필요
    - fs 옵션으로 백업 할 경우 반드시 shared file system 적용 => nfs-server 구성 필요 
    - 클러스터 내 모든 노드에 path.repo 설정 후 재시작

#### NFS Server Setting
1. NFS 서버 구성
    -  설치 및 셋업
    ```shell
    # NFS 서버 패키지 설치
    sudo dnf install -y nfs-utils
    # NFS 사용할 디렉터리 설치
    sudo mkdir /data//NFS
    # 권한/소유권 설정
    sudo chown nobody:nobody /data/NFS
    sudo chmod -R 777 /data/NFS
    # NFS 서버 Exports 설정 (공유 디렉터리 구성)
    # <공유할 디렉토리> <client-IP>(rw,sync,no_subtree_check)
    # 이번 과정에서는 /data/NFS 192.168.1.*(rw,sync,no_substree_check) 로 입력함
    sudo vi /etc/exports 
    # NFS 서버 시작
    sudo systemctl start nfs-server.service
    # 재부팅시 자동으로 시작 설정
    sudo systemctl enable nfs-server.service    
    ```
    - NFS 공유 디렉터리 정상 동작 확인
    ```shell
    # exportfs -option
    # options
    # a: 모든 공유 디렉터리를 내보내거나 내보내지 않음
    # v: 자세한 출력
    # r: 모든 공유 디렉터리를 다시 내보내고, 디럭테러 밑의 파일들에 대한 동기화
    # s: 현재 내보내기 대상 리스트 출력
    sudo exportfs -v 
    ```
1. 방화벽 처리
    ```shell
    # 방화벽 확인
    sudo firewall-cmd --list-all 
    sudo firewall-cmd --permanent --add-service=nfs
    sudo firewall-cmd --permanent --add-service=rpc-bind
    sudo firewall-cmd --permanent --add-service=mountd
    sudo firewall-cmd --reload
    ```

1. NFS 클라이언트 구성
    - 클라이언트 설치 및 구성
    ```shell
    # 설치
    sudo dnf install -y nfs-utils nfs4-acl-tools
    # sudo yum install -y nfs-utils nfs4-acl-tools
    # NFS 로컬 마운트 경로 생성
    sudo mkdir /data/NFS
    # NFS 공유디렉터리를 로컬 경로로 마운트
    sudo mount -t nfs ${ip_addr}:/data/NFS /data/NFS
    # 마운트 확인
    mount | grep nfs
    ```
    - 재부팅 시 마운트 자동 등록 처리
    ```shell
    # 접근권한 없을 시 etc/fstab vi 로 열어서 아래 내용으로 편잡
    echo "${ip_addr}:/data/NFS    /data/NFS   nfs defaults 0 0 ">>/etc/fstab
    # 등록 확인
    cat /etc/fstab
    ```

#### snapshot 생성
```shell
# 스냅샷 리파지토리 생성
curl -X PUT "http://${ip_addr}:9205/_snapshot/리파지토리명?pretty" -H 'Content-Type: application/json' -d'
{
    "type": "fs",
    "settings": {
        "location": "/data/NFS", #NFS 셋업된 폴더
        "compress": true
    }
}'

# 모든 인덱스 스냅샷 생성
curl -X PUT "http://${ip_addr}:9205/_snapshot/위에서생성한리피지토리명/스냅샷이름?wait_for_completion=true&pretty"

# 특정 인덱스만 스냅샷 생성
curl -X PUT "http://${ip_addr}:9205/_snapshot/위에서생성한리피지토리명/스냅샷이름?wait_for_completion=true&pretty" -H 'Content-Type: application/json' -d'
{
  "indices": "인덱스명",
  "ignore_unavailable": true,
  "include_global_state": false,
  "metadata": {
    "taken_by": "Bruno",
    "taken_because": "Backup of the index named ACCOUNTS"
  }
}
'
curl -X GET "http://${ip_addr}:9205/_cat/snapshots/위에서생성한리피지토리명?v&s=id&pretty"
```
#### snapshot 복원
```shell
curl -X POST "http://${ip_addr}:9205/_snapshot/위에서생성한리피지토리명/스냅샷이름/_restore?pretty"
```

### ◆ trobule shooting
#### node lock 에러
```
Caused by: java.lang.IllegalStateException: failed to obtain node locks, tried [
[데이터 폴더 경로]] with lock id [0]; maybe these
 locations are not writable or multiple nodes were started without increasing [n
ode.max_local_storage_nodes] (was [1])
```
[원인/해결법](https://stackoverflow.com/questions/45354456/elasticsearch-error-while-trying-to-start-the-service-on-windows)
- 한대의 컴퓨터에서 여러 노드를 운영 시 인덱스 저장경로를 노드끼리 공유하기 위해선  node.max_local_storage_nodes 값을 2이상 주어야함 -> 추천되지 않음 (7버전 부터는 설정값 없어진듯)
- 설치 후 테스트하면서 실행 시 사용한 노드가 데이터 폴더를 선점하면서 생긴 오류로 보임 -> 삭제 후 재설치함
#### 클러스터 메모리 관련 세팅 에러
```
bootstrap check failure [1] of [2]: memory locking requested for elasticsearch process but memory is not locked
bootstrap check failure [1] of [1]: max virtual memory areas vm.max_map_count [65530] is too low, increase to at least [262144]
```
- bootstrap.memory_lock 설정 활성화
- user의 메모리 락 제한 없애기 
    - /etc/security/limits.conf 파일에 유저명 - memlock unlimited 추가
- 가상메모리에서 생성 가능한 mmap 개수 최소 262,114개 이상으로 설정
    - /etc/sysctl.conf에 vm.max_map_count=262144 내용 추가 (본 서버에서는 /etc/sysctl.d/elasticsearchSpecifications.conf 에 내용 추가함)
    [원인/해결법](https://kyeoneee.tistory.com/58)

#### 클러스터 마스터 노드 연결 에러
```
[2021-06-04T14:20:47,337][WARN ][o.e.d.HandshakingTransportAddressConnector] [euclid-elstic-data-node1] [connectToRemoteMasterNode[${ip_addr}:9305]] completed handshake with [{euclid-elstic-master-node}{-QTA_EsWSo6Kfk8jYhf6oA}{Q1g9y4VPRCqe4MfcBXww0w}{172.17.0.1}{172.17.0.1:9305}{m}{xpack.installed=true, transform.node=false}] but followup connection failed
```
- 서버 간 노드를 찾을 때 바인드 된 ip로 찾
- network.publish_host 값을 해당 서버 내부망 ip로 명시해서 해결함
    - 추측: 도커 elasticsearch 네트워크 접근 후 응답을 못받아서 연결 오류 난 것은 아닐까 추측 중


### Systemctl Service 등록
- sudo vi  /usr/lib/systemd/system/elasticsearch.service 에 아래 내용 등록
- 제대로 등록되었다면
```shell
# 시작
sudo systemctl start elasticserach.service
# 상태확인
sudo systemctl status elasticserach.service
# 종료
sudo systemctl stop elasticserach.service
```
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