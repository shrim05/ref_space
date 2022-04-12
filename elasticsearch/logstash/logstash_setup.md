- [logstash 설치 및 설정](#logstash-설치-및-설정)
  - [install](#install)
  - [config](#config)
    - [component](#component)
      - [inputs](#inputs)
      - [filters](#filters)
      - [outputs](#outputs)
      - [codecs](#codecs)
    - [보안설정](#보안설정)
      - [secrets keystore](#secrets-keystore)
    - [설정파일 상세](#설정파일-상세)
      - [logstash.yml](#logstashyml)
      - [config file](#config-file)
      - [log4j2.properties](#log4j2properties)
    - [example](#example)
  - [options](#options)
  - [plug-in](#plug-in)
  - [trouble shoot](#trouble-shoot)
  - [QNA](#qna)
## logstash 설치 및 설정
- 작성: 권영호 (mr.kwon05@gmail.com)
- last modified: 2022.01.12
- version: 
  - os: centos8
  - logstash: 7.16.2
  - elasticsearch: 7.13.1
  - java: 1.8.0

### install
[공식홈](https://www.elastic.co/guide/en/logstash/current/getting-started-with-logstash.html)
- LS_JAVA_HOME 환경변수 설정
- Binary 파일 설치
  - https://www.elastic.co/downloads 에서 다운로드 후 unpack
```shell
wget https://artifacts.elastic.co/downloads/logstash/logstash-7.16.2-linux-x86_64.tar.gz
tar -xvf logstash-7.16.2-linux-x86_64.tar.gz
cd logstash-7.16.2
# 작동 테스트
bin/logstash -e 'input {stdin{}} output{stdout{}}' 
```

### config
#### component
##### inputs
- file
- syslog: RFC3164 포맷에 맞춰 syslog parsing
- redis: redis channel 과 list 읽음. 보통 redis 가 브로커, logstash가 shipper 역할로 설정
- beats
[그 외 input plug-in](https://www.elastic.co/guide/en/logstash/current/input-plugins.html)
##### filters
- grok: 비정형 텍스트 변환/구조화
- mutate: event 필드 변환
- drop
- clone
- geoip: ip주소 기반 지리정보 추가
[그 외 filter plug-in](https://www.elastic.co/guide/en/logstash/current/filter-plugins.html)
##### outputs
- elasticsearch
- file
- graphite: 성능,시계열 등 숫자 데이터 모니터링 , 그래프화 [graphite](https://graphite.readthedocs.io/en/latest/overview.html)
- statsd: counter, time 등 통계데이터 처리 (통계 데이터 집계 처리)
[그 외 output plug-in](https://www.elastic.co/guide/en/logstash/current/output-plugins.html)
##### codecs
- json
- multiline: 예외, traceback 같은 여러줄의 텍스트를 합쳐줌

#### 보안설정
##### secrets keystore
- logstash.yml 이나 /conf.d/*.conf 에 있는 설정 파일들에서 사용 가능
- conf 파일에서는 "${key_name}" 형식으로 사용
- logstash.yml에서는 ${key_name} 으로 사용
```shell
# 키스토어 활성화
bin/logstash-keystore create
# 키 저장
bin/logstash-keystore add KEY_NAME
# 키 리스트
bin/logstash-keystore list
# 키 삭제
bin/logstash-keystore remove KEY_NAME
```

#### 설정파일 상세
##### logstash.yml
- 실행관련 설정 (파이프라인 설정, 설정파일 위치, 로깅 옵션 등)
- command-line flags 로도 설정가능함 (커맨드라인 명령어가 우선함)
- bash-style로 환경변수값 사용 가능 (${NAME} or ${SOME_VARIABLE:default_value}등)
[옵션상세](https://www.elastic.co/guide/en/logstash/current/logstash-settings-file.html)


##### config file
- input, filter, output 구조
- value types
  - Array: 잘 사용되지않음. hashes 리스트나 타입 체크가 필요없는 혼합 속성에 사용 
    - users => [ {id => 1, name => bob}, {id => 2, name => jane} ]
  - Lists: 

##### log4j2.properties
- logging 관련 설정 파일
- logstash 재시작해야 적용
- API 를 이용해 임시로 로깅 설정 변경 가능
- API 포트 기본값 tpc:9600 , 다른 포트 사용하려면 logstash 시작할 때 --api.http.port flag로 설정
```shell
# 현재 로깅 설정 확인
curl -XGET 'localhost:9600/_node/logging?pretty'
# 로깅 레벨 변경
curl -XPUT 'localhost:9600/_node/logging?pretty' -H 'Content-Type: application/json' -d'
{
    "logger.logstash.outputs.elasticsearch" : "DEBUG"
}
'
# 로깅설정 리셋
curl -XPUT 'localhost:9600/_node/logging/reset?pretty'
```

#### example


### options
- config 옵션 
  - execute code example: 
  ```shell
  # --config.option
  bin/logstash -f first-pipeline.conf --config.test_and_exit
  ```
  - test_and_exit: 설정파일 문법 오류 확인
  - reload.automatic: 설정변경 자동 반영

### plug-in

### trouble shoot


### QNA
- 다중 input, output 설정 방법은?
  - [multiple input & output](https://www.elastic.co/guide/en/logstash/current/multiple-input-output-plugins.html)
  - [multiple pipelines](https://www.elastic.co/guide/en/logstash/current/multiple-pipelines.html) input / output안에 원하는 만큼 정의
  - 
- 장애/중단 후 재시작 시 작동 방식은 (데이터 유실 등 확인)?
  - filebeat의 경우 data/registry로 읽은 데이터 범위 관리하는 것으로 보임
  - logstash 는 기본적으로 파이프라인 스테이지간 이벤트 버퍼로 in-memory queue 방식을 씀 -> 비정상적인 종료 시 데이터 손실 => 디스크에 쓰는 방식 (persistent queues) 으로 대응 가능
- 엘라스틱서치 index 자동 생성 시 인덱스의 volume 관리방법은?
  - 날짜별로 index 생성? (일/월/년?) -> 설정방법은?
- 이상/error 발생 시 알람 기능 설정은?
