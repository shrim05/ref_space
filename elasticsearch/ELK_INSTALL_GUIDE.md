# ELK STACK 설치 가이드 [출처](https://github.com/ksundong/docker-elk-kor)
작성자/작성일: 권영호/2021.04.06
## 소개
- 해당 가이드는 출처에 표기된 elk stack 설치 메뉴얼을 참조하여, 유클리드소프트 서버 환경에서 간편하게 설치할 수 있도록 정리한 문서입니다.
- 상세 내용의 파악이 필요하거나, 본 문서 외 내용의 설정이 필요하면 출처의 메뉴얼 또는 엘라스틱서치 공식 메뉴얼의 절차를 따라 수행하십시오.

## 설치환경
- OS: CentOS 8 (3번서버)
- docker version: 20.10.5 
- docker-compose version: 1.27.4


## 설치방법
- git clone 을 통해 소스를 내려 받는다.
```shell
git clone https://github.com/ksundong/docker-elk-kor

- 해당 문서에서는 기본 세팅된 환경설정을 바로 사용하는 것으로, 네트워크나 기타 세팅의 변경은 공식 메뉴얼을 참고하여 진행한다.
```shell
# docker-elk-kor 폴더 이동
cd docker-elk-kor
# docker-compose 를 통한 build 및 detach(백그라운드 실행)
docker-compose up --build -d
```
- 작동 실행 확인
    - docker-compose up --build 이 후 서버 가동까지 수분 소요됨
    - 설치된 host:9200(기본포트로 접속해서 서버 관련 명세가 뜨면 서버 준비 완료 된 것임)
        - ex: 웹브라우저에서 localhost:9200 로 접속 =>  서버명세와 함께 "tagline" : "You Know, for Search" 문구가 뜸
    - kibana에 접속하여 서버가 준비 되었는지도 확인가능 (kibana 기본 포트 5601)
        - ex: http://localhost:5601 이 접속 가능하면 엘라스틱서치도 준비 완료 된 것임



## 아래 내용은 https://github.com/deviantony/docker-elk.git 기준이며, https://github.com/ksundong/docker-elk-kor 버전에 이미 적용되었으므로 참고 하지 아니함
# git clone을 통해 docker-elk 폴더가 생성 됨을 가정하고 설명함
```
- 필요없는 기능이나 유료기능(xpack)을 삭제한다.
```shell
vi docker-elk/elasticsearch/config/elasticsearch.yml
# xpack.license.self_generated.type: trial
# xpack.security.enabled: true
# xpack.monitoring.collection.enabled: true
# 위 xpack 관련 설정 주석 처리 또는 삭제

vi docker-elk/kibana/config/kibana.yml
# monitoring.ui.container.elasticsearch.enabled: true
# elasticsearch.username: elastic
# elasticsearch.password: changeme
# 위 xpack 관련 설정 주석 처리 또는 삭제

vi docker-elk/logstash/config/logstash.yml
# xpack.monitoring.elasticsearch.hosts: [ "http://elasticsearch:9200" ]
# xpack.monitoring.enabled: true
# xpack.monitoring.elasticsearch.username: elastic
# xpack.monitoring.elasticsearch.password: changeme
# 위 xpack 관련 설정 주석 처리 또는 삭제
```
- 한글 토크나이저인 nori-tokenizer 플러그인을 설치 명세를 Dockerfile에 추가한다
```shell
vi docker-elk/elasticsearch/Dockerfile
# FROM docker.elastic.co/elasticsearch/elasticsearch:${ELK_VERSION} 라인 아래에 
# RUN elasticsearch-plugin install analysis-nori 
# 위 문구 추가
```
