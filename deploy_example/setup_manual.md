- [운영 환경 구성 메뉴얼](#운영-환경-구성-메뉴얼)
  - [폐쇄망 yum 설치 repo 등록](#폐쇄망-yum-설치-repo-등록)
  - [Java 설치](#java-설치)
  - [Anaconda 설치](#anaconda-설치)
  - [Docker 설치](#docker-설치)
  - [docker registry](#docker-registry)
  - [Mysql 5.7 설치](#mysql-57-설치)
  - [Elasticsearch Cluster 설치](#elasticsearch-cluster-설치)
- [사용 포트 정리](#사용-포트-정리)

# 운영 환경 구성 메뉴얼

## 폐쇄망 yum 설치 repo 등록
[참고](https://oingdaddy.tistory.com/134)
```
wget --recursive --no-parent http://ftp.kaist.ac.kr/CentOS/8/extras/x86_64/
인터넷망 /설치경로/ftp.kaist.ac.kr/CentOS/7/extras/x86_64/  -> 폐쇄망 /임의의경로/kaistrepo/
cd /etc/yum.repos.d
vi kaist.repo

[kaist-repo]
name=kaistrepo
baseurl=file:///app/temp/kaistrepo
enabled=1
gpgcheck=0

yum clean all
yum repo reload
```

## Java 설치
- yum 또는 압축파일로 설치
[yum설치](https://mrgamza.tistory.com/705)
[파일설치](https://velog.io/@zeesoo/LinuxRHEL7-%EB%A0%88%EB%93%9C%ED%96%87-Oracle-JDK-1.8-%EC%84%A4%EC%B9%98)
```shell
# yum 으로 설치 시
    yum -y install java-1.8.0-openjdk-devel.x86_64
# 파일로 설치 시
    # 압축풀기
    tar -zvxf jdk-8u281-linux-i586.tar.gz(파일이름)
    # 위치이동
    mv jdk1.8.0_281/ /usr/local/lib
```
- 환경변수 등록
```shell
sudo vi /etc/profile
JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.232.b09-0.el8_0.x86_64
JRE_HOME=$JAVA_HOME/jre
PATH=$PATH:$JAVA_HOME/bin:$JRE_HOME/bin
export JAVA_HOME
export JRE_HOME
source /etc/profile
```
- /lib/ld-linux.so.2 에러가 발생할 경우
```
yum install ld-linux.so.2
```

## Anaconda 설치
[설치참고](https://phoenixnap.com/kb/install-anaconda-on-centos-8)

```shell
wget –P ~/Downloads https://repo.anaconda.com/archive/Anaconda3.2020.02-Linux-x86_64.sh
cd ~/Downloads
sha256sum Anaconda3.2020.02-Linux-x86_64.sh
```


## Docker 설치


* **yum package 설치 및 repo 등록**
    ```
    $ sudo yum install -y yum-utils

    $ sudo yum-config-manager \
        --add-repo \
        https://download.docker.com/linux/centos/docker-ce.repo
    ```
* **docker engine 설치**
    ```
    $ sudo yum install docker-ce docker-ce-cli containerd.io
    ```
    2020.10.30 기준 Centos8 에선 Podman 컨테이너 엔진이 설치되어 있어 docker repo 최신 버전 설치 시 containerd.io 의존성 문제가 발생하여 설치가 되지 않음. 

    해결방법1: docker 버전을 낮춰 설치(--nobest 옵션으로 설치 dnf install --nobest docker-ce ) Centos8 부터는 yum 대신 dnf 가 기본 패키지 관리자

    해결방법2: podman, buildah 삭제 후 docker 설치

    여기서는 2번 방법으로 진행
    ```
    $ sudo yum -y remove podman buildah
    $ sudo yum install docker-ce docker-ce-cli containerd.io
    ```
* **docker 설치 확인**
    ```
    $ docker --vesion
    ```

* **설치 확인 및 권한 설정**
    ```
    docker-compose --version
    ```
    docker는 기본적으로 root 권한이 필요하기 때문에 설치 사용자가 root 가 아니라면 해당 사용자를 docker 그룹에 추가
    ```
    $ sudo usermod -aG docker $USER # 현재 접속중인 사용자에게 권한주기
    $ sudo usermod -aG docker your-user # your-user 사용자에게 권한주기
    $ sudo systemctl restart docker
    ```
    그룹 설정 후 docker 재시작 맟 사용자로 로그아웃 후 다시 로그인

* **docker-compose 설치** [docker-compse install doc](https://docs.docker.com/compose/install/)
    ```
    $ sudo curl -L "https://github.com/docker/compose/releases/download/*2*4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    $ sudo chmod +x /usr/local/bin/docker-compose
    ```

* **docker 기본 폴더 변경**
docker 기본 폴더를 용량이 큰 경로로 변경 추천. 기본 경로 /var/lib/docker/ 에 설치되기 때문에 사용 중 root 용량이 가득차는 경우가 생김. 
os 마다 수정해야하는 파일의 경로가 다를 수 있고, 수정하는 방법도 여러가지임. 보통 docker.service 파일을 수정하거나 daemon.json 파일을 추가/수정하는 방법으로 함.
여기서는 docker.service를 수정하여 진행
    * 데이터 경로 확인
    ```
    $ sudo docker info | grep Root
    Docker Root Dir:  /var/lib/docker
    ```
    * 변경될 폴더 생성(여기서는 /data/docker_dir)
    ```
    $ mkdir -p /data/docker_dir
    ```
    $ sudo service docker status
    Loaded: loaded (/lib/systemd/system/docker.service; enabled; vendor preset: enabled) => docker.service 경로 확인
    $ sudo vi 위에서 확인한 경로
    ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock --data-root=/data/docker_dir
    ```

    * docker 및 데몬 재시작
    $ sudo systemctl daemon-reload

    * docker 프로세스 중지
    ```
    $ sudo systemctl stop docker
    ```
    ```
    $ sudo systemctl start docker.service
    ```
    * 변경 경로 확인 (docker의 기본 정보는 docker info로 확인 가능)
    ```
    $ docker info | grep Root
    ```

* **daemon.json 을 수정하는 경우** /etc/docker/daemon.json (daemon.josn 파일 없으면 생성해서 사용) 에 아래 내용 추가
    ```
       {
           "data-root" : "/변경경로"
       }
    ```
    예)
    ```
        {
            "data-root" : "/data/docker_dir"
        }
    ```

* **centos8에서 도커 컨테이너 간 연결이 안될 경우**
참고: [CentOS8,Fedora 에서 컨테이너 HOST 사용불가문제](https://ggami.net/648/docker-centos8-fedora%EC%97%90%EC%84%9C-%EC%BB%A8%ED%85%8C%EC%9D%B4%EB%84%88-host-%EC%82%AC%EC%9A%A9-%EB%B6%88%EA%B0%80%EB%8A%A5%ED%95%9C-%EB%AC%B8%EC%A0%9C-%ED%95%B4%EA%B2%B0%EB%B0%A9%EB%B2%95/)

- centos8은 기본 네트워크 패킷 필터링으로 nftables를 사용하면서 방화벽 설정 문제로 docker에서 컨테이너간 통신이 안되는 경우가 생김. 정석적으로는 nftables 에 맞는 설정을 해야하지만 네트워크 부분까지 파고 들어야하므로 iptables로 설정을 변경 하는 정도로 해결함.
참고: [nftables 가 iptables 보다 나은점](https://blog.cloudflare.com/ko/how-to-drop-10-million-packets-ko/)

firewalld.conf 파일의 FirewallBackend 값을 iptables로 변경
    
    ```
    $ sudo vi /etc/firewalld/firewalld.conf
    FirewallBackend=iptables 로 변경
    $ sudo systemctl restart firewalld.service
    ```

## docker registry
[참고](https://ratseno.tistory.com/89)
1. 초기 설정
    <!-- insecure registry 등록 후 docker restart-->
    1-1. $ sudo systemctl stop docker 
    <!-- 도커 설치 버전, os 버전 등에 따라 아래 명령어가 안될 수 있음. /etc/docker/daemon.json 파일(없으면 생성) 후 {  "insecure-registries": ["localhost:5000"]} 추가 -->
    1-2. $ sudo docker deamon --insecure-registry localhost:5000
    1-3. $ sudo systemctl start docker

2. docker registry server 구축
    1. $ sudo docker 
    2. $ sudo docker run -d -p 5000:5000 --name docker-registry  \
    -v /tmp/registry:/tmp/registry \
    registry
<!-- 
    docker tag <이미지명:태그> <hub 계정명>/<hub 레파지토리명> 으로 hub로 올릴 이미지를 복사 합니다.
    예시) docker tag dev-web:0.2 rogerjo/dev-web
    docker push rogerjo/dev-web 명령으로 도커허브에 이미지를 push합니다.

    private registry를 사용할 때는 <계정아이디>부분에 내 registry의 url주소를 사용
    ex) docker tag hello-world:1.0 localhost:5000/hello-world
-->

1. 원격지에서 사용하기 위해 ssl 인증 설정
    - openssl 버전 확인하기
    $ openssl version

    - certs 폴더에 개인키 생성하기. 비밀번호를 입력하자. 
<!-- $ mkdir certs && cd certs -->
    $ openssl genrsa -des3 -out server.key 2048

    # 인증 요청서 생성
<!-- $ openssl req -new -key {keyfilename}.key -out {csrfilename}.csr -->
    $ openssl req -new -key server.key -out {csrFileName}.csr

<!-- Country Name (2 letter code) [XX]:KR
    State or Province Name (full name) []:Seoul
    Locality Name (eg, city) [Default City]:Seongdonggu
    Organization Name (eg, company) [Default Company Ltd]:NOVEMBERDE
    Organizational Unit Name (eg, section) []:TEST
    Common Name (eg, your name or your server\'s hostname) []: ip주소 또는 도메인명
    Email Address []: -->

    # 생성된 파일 확인하기
    $ ll

    # 개인키에서 패스워드 제거하기
    $ cp server.key server.key.origin && openssl rsa -in server.key.origin -out server.key && rm server.key.origin
    

    # SAN 설정을 위한 Config 파일 생성
    $ echo subjectAltName=IP:{registryServerIP},IP:127.0.0.1 > extfile.cnf

    # 인증서 생성하기.
    $ openssl x509 -req -days 730 -in {csrFileName}.csr -signkey server.key -out  {certFileName}.crt 

1. 인증서 발급 후 registry 재 가동
    1. $ docker run -d -p 5000:5000 --name docker-registry -v /tmp/registry:/tmp/registry -v /home/analysis-2/certs/docker_certs:/certs -e REGISTRY_HTTP_ADDR=0.0.0.0:5000  -e REGISTRY_HTTP_TLS_CERTIFCATE=/certs/{certFileName}.crt -e REGISTRY_HTTP_TLS_KEY=/certs/server.key registry

<!-- docker run -itd --name={registryContainerName} -v {hostCertDir}:{contCertDir} \
-e REGISTRY_HTTP_ADDR=0.0.0.0:5000 \
-e REGISTRY_HTTP_TLS_CERTIFICATE={contCertDir}/server.crt \
-e REGISTRY_HTTP_TLS_KEY={contCertDir}/server.key -p 5000:5000 registry -->


1. Registry서버에서 생성했던 SSL 인증서를 클라이언트 머신으로 복사
    1. 적절한 방법으로 클라이언트 머신으로 복사
    ex)scp {복사하려는 파일명} {서버 사용자 아이디}@{서버 주소}:{서버의 복사 경로 위치}
    1. 변경 내용 시스템 반영
    <<우분투 기준>>
    $ echo {certFileName}.crt >> /etc/ca-certificates.conf
    $ update-ca-certificates
    <<centos 기준>>
    $ cp {certFileName}.crt /etc/pki/ca-trust/source/anchors/
    $ update-ca-trust
    1. 클라이언트 도커 데몬 재시작
    $ sudo service docker restart

2. image pull/push
    $ docker tag {srcImage} {registryServerIP}:{registryServerPort}/{dstImage}
    $ docker push {targetImage}

1. "server gave HTTP response to HTTPS client" error 발생시 (보안 상 비추천. 안전한 상황에서 사용 but 사설인증서의 경우 발생 -> 다른 안전한 방식 탐색중)
    daemon.json 파일에 { "insecure-registries" : ["host_ip_address:port"] } 값 추가
    daemon.json 기본 위치 : linux -> /etc/docker/daemon.json (없으면 생성)
    windows -> /ProgramData/Docker/daemon.json 
    window docker-desktop 사용할 경우 : settings -> docker engine 에서 값 추가

## Mysql 5.7 설치

[참고](https://hyunmin1906.tistory.com/227)

```shell
# mysql download
wget https://downloads.mysql.com/archives/get/p/23/file/mysql-5.7.28-1.el7.x86_64.rpm-bundle.tar 
tar -xvf mysql-5.7.28-1.el7.x86_64.rpm-bundle.tar 
sudo yum localinstall mysql-community-*

# mysql config 
sudo vim /etc/my.cnf 

# 서비스 구동
sudo systemctl start mysqld 
sudo systemctl status mysqld 

# 암호/보안 설정
cat /var/log/mysqld.log | grep "temporary password"
mysql_secure_installation
# 또는 무제약모드로 mysql root 비밀번호 변경
sudo systemctl stop mysqld
sudo systemctl set-environment MYSQLD_OPTS="--skip-grant-tables"  
sudo systemctl start mysqld 
create user '유저이름'@'%' identified by '유저비밀번호'; 
grant all privileges on 데이터베이스명.* to '유저이름'@'%'; 
CREATE DATABASE 데이터베이스명 default CHARACTER SET UTF8; 
flush privileges; 
exit 

sudo systemctl stop mysqld 

sudo systemctl unset-environment MYSQLD_OPTS 

sudo systemctl start mysqld 
```
- 현재 사용 중 인 세팅값
```txt
#
# This group is read both by the client and the server
# use it for options that affect everything
#
[client-server]

#
# include *.cnf from the config directory
#
!includedir /etc/my.cnf.d

[mysqld]
default-time-zone=Asia/Seoul
datadir=/data/mysql
socket=/data/mysql/mysql.sock
performance_schema = ON
slow_query_log = ON
long_query_time = 10
log-slow-verbosity = 'query_plan,innodb'
slow_query_log_file = /data/log/mysql_log/slow/mysvc01-slow.log
max_allowed_packet=100M
skip-external-locking
key_buffer_size = 384M
table_open_cache = 512
sort_buffer_size = 2M
read_buffer_size = 2M
read_rnd_buffer_size = 8M
myisam_sort_buffer_size = 64M
thread_cache_size = 8
query_cache_size = 32M

#dns query
skip-name-resolve

###chracter
character-set-client-handshake=FALSE
init_connect = SET collation_connection = utf8_general_ci
init_connect = SET NAMES utf8
character-set-server = utf8
collation-server = utf8_general_ci


#connection
max_connections = 1000
max_connect_errors = 1000
wait_timeout= 10000

### MyISAM Spectific options
##default-storage-engine = myisam
key_buffer_size = 32M
bulk_insert_buffer_size = 64M
myisam_sort_buffer_size = 128M
myisam_max_sort_file_size = 10G
myisam_repair_threads = 1


### INNODB Spectific options
default-storage-engine = InnoDB
#skip-innodb
#innodb_additional_mem_pool_size = 16M
innodb_data_file_path = ibdata1:100M:autoextend
innodb_write_io_threads = 16
innodb_read_io_threads = 16
innodb_thread_concurrency = 16
innodb_flush_log_at_trx_commit = 1
innodb_log_files_in_group = 3
innodb_max_dirty_pages_pct = 90
innodb_lock_wait_timeout = 120
innodb_buffer_pool_size = 16G
innodb_buffer_pool_instances = 8
innodb_buffer_pool_chunk_size = 512M
innodb_log_file_size = 1G
innodb_log_buffer_size = 100MB

[client]
socket=/data/mysql/mysql.sock

[myisamchk]
key_buffer_size = 256M
sort_buffer_size = 256M
read_buffer = 2M
write_buffer = 2M

```

## Elasticsearch Cluster 설치
Single muchine에서 설치하기 때문에 아래 설정들은 다르게 줘야함
http.port
transport.tcp.port
path_data
path_logs
path_pid
node.name




# 사용 포트 정리
* Staging-server
  - ssh: 22
  - elasticsearch
    - es: 
      - http: 9200
      - tcp: 9300
    - kibana: 5601

* Analysis-server
  - mysql : 3306
  - limenet_analysis_engine
    - backend: 8000
    - load-balancer: 8600
  - ssh: 22
