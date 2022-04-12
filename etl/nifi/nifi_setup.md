# nifi install & setup

- [nifi install & setup](#nifi-install--setup)
  - [Doc Info](#doc-info)
    - [작성: 권영호 (mr.kwon05@gmail.com)](#작성-권영호-mrkwon05gmailcom)
    - [last modified: 2022.03.07](#last-modified-20220307)
  - [설치 (On-Premise)](#설치-on-premise)
    - [설치 환경](#설치-환경)
    - [설치과정](#설치과정)
  - [설치 (Container-Clustering)](#설치-container-clustering)
    - [설치환경](#설치환경)
## Doc Info
### 작성: 권영호 (mr.kwon05@gmail.com)
### last modified: 2022.03.07

## 설치 (On-Premise)
### 설치 환경
- OS: Ubuntu 20.04.1 LTS (Focal Fossa) WSL2
- Nifi: nifi-1.15.3-bin.tar.gz
- java: openjdk-11-jdk
### 설치과정
- Download (https://www.apache.org/dyn/closer.lua?path=/nifi/1.15.3/nifi-1.15.3-bin.tar.gz)
```shell
# 압축해제
tar xvf nifi-1.15.3-bin.tar.gz 
# foreground 실행
bin/nifi.sh run
# background 실행
bin/nifi.sh start
# 상태확인
bin/nifi.sh status
# 중단
bin/nifi.sh stop
# Service 등록
bin/nifi.sh install
# 유저 등록
bin/nifi.sh set-single-user-credentials <username> <password>
# bin/nifi.sh set-single-user-credentials nifi nifitest1234

```
## 설치 (Container-Clustering)
### 설치환경
- Docker Container
- Resource Manager: Zookeeper