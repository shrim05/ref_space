## Docker install (Linux)
[docker install docs](https://docs.docker.com/engine/install/)
예제 환경
OS : CentOS 8
작성일 : 2020.10.30

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