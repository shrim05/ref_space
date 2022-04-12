## 1. 초기 설정
    <!-- insecure registry 등록 후 docker restart-->
    1-1. $ sudo systemctl stop docker 
    <!-- 도커 설치 버전, os 버전 등에 따라 아래 명령어가 안될 수 있음. /etc/docker/daemon.json 파일(없으면 생성) 후 {  "insecure-registries": ["localhost:5000"]} 추가 -->
    1-2. $ sudo docker deamon --insecure-registry localhost:5000
    1-3. $ sudo systemctl start docker

## 2. docker registry server 구축
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

## 3. 원격지에서 사용하기 위해 ssl 인증 설정
    # openssl 버전 확인하기
    $ openssl version

    # certs 폴더에 개인키 생성하기. 비밀번호를 입력하자. 
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

## 4. 인증서 발급 후 registry 재 가동
    1. $ docker run -d -p 5000:5000 --name docker-registry -v /tmp/registry:/tmp/registry -v /home/analysis-2/certs/docker_certs:/certs -e REGISTRY_HTTP_ADDR=0.0.0.0:5000  -e REGISTRY_HTTP_TLS_CERTIFCATE=/certs/{certFileName}.crt -e REGISTRY_HTTP_TLS_KEY=/certs/server.key registry

<!-- docker run -itd --name={registryContainerName} -v {hostCertDir}:{contCertDir} \
-e REGISTRY_HTTP_ADDR=0.0.0.0:5000 \
-e REGISTRY_HTTP_TLS_CERTIFICATE={contCertDir}/server.crt \
-e REGISTRY_HTTP_TLS_KEY={contCertDir}/server.key -p 5000:5000 registry -->


## 5. Registry서버에서 생성했던 SSL 인증서를 클라이언트 머신으로 복사
    1. 적절한 방법으로 클라이언트 머신으로 복사
    ex)scp {복사하려는 파일명} {서버 사용자 아이디}@{서버 주소}:{서버의 복사 경로 위치}
    2. 변경 내용 시스템 반영
    <<우분투 기준>>
    $ echo {certFileName}.crt >> /etc/ca-certificates.conf
    $ update-ca-certificates
    <<centos 기준>>
    $ cp {certFileName}.crt /etc/pki/ca-trust/source/anchors/
    $ update-ca-trust
    3. 클라이언트 도커 데몬 재시작
    $ sudo service docker restart

## 6. image pull/push
    $ docker tag {srcImage} {registryServerIP}:{registryServerPort}/{dstImage}
    $ docker push {targetImage}

##  "server gave HTTP response to HTTPS client" error 발생시 (보안 상 비추천. 안전한 상황에서 사용 but 사설인증서의 경우 발생 -> 다른 안전한 방식 탐색중)
    daemon.json 파일에 { "insecure-registries" : ["host_ip_address:port"] } 값 추가
    daemon.json 기본 위치 : linux -> /etc/docker/daemon.json (없으면 생성)
    windows -> /ProgramData/Docker/daemon.json 
    window docker-desktop 사용할 경우 : settings -> docker engine 에서 값 추가
