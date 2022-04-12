
- [filebeat 설치 및 설정](#filebeat-설치-및-설정)
  - [install](#install)
  - [일반적인 실행 순서](#일반적인-실행-순서)
  - [config sample](#config-sample)
    - [유용한 설정](#유용한-설정)
    - [filebeat.yml 설정](#filebeatyml-설정)
      - [logfile ->](#logfile--)
        - [elasticsearch](#elasticsearch)
        - [logstash](#logstash)
      - [docker container ->](#docker-container--)
      - [kibana](#kibana)
  - [plug-in](#plug-in)
  - [trouble shoot](#trouble-shoot)

## filebeat 설치 및 설정
- 작성: 권영호 (mr.kwon05@gmail.com)
- last modified: 2022.01.12
- version: 
  - os: centos8
  - logstash: 7.16.2
  - elasticsearch: 7.13.1
  - java: 1.8.0
### install
[공식홈](https://www.elastic.co/guide/en/beats/filebeat/7.16/filebeat-installation-configuration.html)

```shell
curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.16.2-linux-x86_64.tar.gz
tar xzvf filebeat-7.16.2-linux-x86_64.tar.gz
```
### 일반적인 실행 순서
1. filebeat.yml 수정
   1. 아웃풋, setup.kibana, filebeat.config.mudles path 설정
2. 모듈활성화 : ./filebeat modules enable 모듈명
3. 활성화된 모듈설정파일 수정
4. setup 명령 실행 ./filebeat setup 
   1. setup 명령으로 인덱스 템플릿 생성, 키바나 대시보드 활성화
5. filebeat 실행(-e: 로그 출력, -d '*': 디버깅 메시지 출력)
### config sample
- 실행방법
```shell
# -e foreground 실행 -c yml파일 지정
./filebeat -e -c filename.yml
```
#### 유용한 설정
- ignore_older: 새로운 파일 탐색 시 오래된 파일 무시
  - input type이 log 인 경우 사용가능
  - 타임스트링 형식으로 값 설정 (10h, 10m 등)
  - 최근 지정시간 전의 로그만 수집
- include_lines 외: 정규표현식으로 필터링 된 라인만 처리
  - include_lines: ['^ERR','^WARN']
  - exclude_lines: ['^DBG']
  - exclude_files: ['\.gz$']
- multiline: 여러줄을 하나의 라인처럼 처리
  - pattern: 패턴이 일치하면 멀티라인으로 인식
  - negate: true 일 시 패턴 일치 조건 반전
  - match: 멀티라인처리 방식. before, after 지정. 패턴이 일치하는 라인을 앞쪽(before)라인 뒤에 붙어거나 , 뒤쪽라인(after)과 함께 붙인다
    - pattern 이 negate 하는 라인을 패턴이 일치하는 라인의 match 쪽에 붙임
#### filebeat.yml 설정
##### logfile ->
###### elasticsearch
  - 엘라스틱서치로 직접 전송
  - filebeat-7.16.2-20ㅋ22.01.12-000001 와 같은 인덱스 생성 후 저장됨
    ```yml
    # filebeat.yml
    filebeat.inputs:
    - type: log
    paths:
        - /data/{INSTALLED_FOLDER}/${INSTALLED_APP}/edap/accesslog.log
    json.message_key: log
    json.keys_under_root: true
    output.elasticsearch:
    hosts: ["host_ip:9200"]  
    username: "elastic"
    password: "changeme"
    ```
###### logstash
  - logstash로 전송
  - logstash 측에서 받을 준비 하고 실행 
  - ./bin/logstash -f config/logstash-sample.conf
    ```conf
    # config/logstash-sample.conf
    input {
      beats {
        port => 5044
      }
    }

    output {
      elasticsearch {
        hosts => ["http://localhost:9200"]
        index => "%{[@metadata][beat]}-%{[@metadata][version]}-%{+YYYY.MM.dd}"
        user => "elastic"
        password => "dbzmfflem"
      }
    }
    ```
  - ./filebeat -e -c to_logstash_test.yml
    ```yml
    # filebeat config
    filebeat.inputs:
    - type: log
      paths:
        - /data/{INSTALLED_FOLDER}/${INSTALLED_APP}/edap/accesslog.log
    output.logstash:
      hosts: ["${ip_addr}:5044"]
    ```
##### docker container ->

##### kibana

### plug-in




### trouble shoot