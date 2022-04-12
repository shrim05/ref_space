## Doc Info
### 작성: 권영호 (mr.kwon05@gmail.com)
### last modified: 2022.03.16

- [Doc Info](#doc-info)
  - [작성: 권영호 (mr.kwon05@gmail.com)](#작성-권영호-mrkwon05gmailcom)
  - [last modified: 2022.03.16](#last-modified-20220316)
- [기본개념](#기본개념)
  - [특징](#특징)
  - [구성요소](#구성요소)
  - [Processor 설정](#processor-설정)
    - [SETTINGS](#settings)
  - [SCHEDULING](#scheduling)
  - [Properties](#properties)
  - [Process Group 설정](#process-group-설정)
    - [General](#general)
- [설정 이관(재활용)](#설정-이관재활용)
  - [템플릿 export/import](#템플릿-exportimport)
  - [Batch 작업 연결](#batch-작업-연결)

## 기본개념
[공식홈](https://nifi.apache.org/docs.html)
[참고](https://www.slideshare.net/combineads/nifi-69730250)
### 특징
- 분산환경 데이터 수집 툴
- 실시간 처리에 특화 <-> 대규모 배치 작업에 적절하지 않음
- 데이터 이동경로 추적 가능 <-> 실행되는 내용 확인 안됨 (성공,실패,출력결과만 확인가능)
- 간단한 데이터 변환 가능 (복잡한 연산은 Spark 연동)
### 구성요소
- flowfile: 데이터 단위
  - Attribute(속성), Content(내용)으로 구성
  - 속성은 키/값 형태, 데이터의 이동/저장에 필요한 정보
  - processor 간 이동 시 포인트 정보 복사
    - FlowFile 생성 시 FlowFile Repository에 속성값, 내용 저장. Content Repository에 내용 저장, Processor 처리 시 마다 Provenance Repository에 FlowFile History 저장
- processor: 데이터 수집, 변환, 저장
  - 기본 150여개 제공, 커스터마이징 가능
  - UpdateAttribute: 속성변경 프로세서
  - MergeContent: 데이터 Merge
  - Splite*: 데이터 분할
  - Convert*: 데이터 타입 변경
- connection: processor 간 연결, flowfile 전달
  - FlowFile의 대기열(Queue)
  - 우선순위, 만료, 부하조절 기능 제공
- 기타:
  - Flow Controller: 스케쥴링 (특정간격, Cron표현식 지원, 클러스터환경 내 동시 실행 방지)
  - Controller Service: Processor간 자원 공유 (DBCPConnectionPool-> DB연결정보 공유)
  - Process Group: Proccessor 그룹관리, 계층구조 제공, Input Port/Output Port 이용 그룹간 데이터 전달 가능
  - Remote Process Group: Site-to-Site 프로토콜 이용, 다른 Nifi 시스템 간 데이터 전달
  - Web Server: Jetty 서버 내장
  - Funnel: 여러 커넥션들의 데이터 모아서 하나의 커넥션으로 생성
  - flow.xml.gz: nifi/conf에 위치. Nifi UI 에서 작업되는 모든 사항에 대해 기록. 설정 backup 용으로 사용 가능. 내용 변경 후 nifi 재시작 시 설정 적용 -> 운영이관 시 내용 변경하여 배포하는 방식 탐색 예정

### Processor 설정 
#### SETTINGS
- Penalty Duration: 데이터(FlowFile) 처리 과정 중 지금 당장은 데이터 처리가 안되지만 나중에 처리될 수 있음을 나타내는 이벤트 발생 시 일정기간 동안 프로세스를 멈춤
- Yield Duration: 프로세서가 더이상 진행이 안될 때 대기 시간. (예: 리모트 서비스로 데이터를 보냈지만 아무 응답이 없을 때)
  - 차이: FlowFile 자체에 일시적인 문제로 진행이 안되면 Penalty Duration 동안 대기, 다른 FlowFiles는 처리됨. (예: PutSFTP 사용 시 같은 파일이름이 있으면 해당 파일은 30초동안 처리 안함, 나머지 FlowFile은 처리 ). Yield는 프로세스 자체가 더이상 진행이 안될 때 적용.
- Automatically Terminate Relationships: 프로세서에 따라 처리 결과 상태값이 여러개 이고, 이에 따른 처리 프로세스를 정의해야한다. 이 때 별다른 처리없이 끝내고 싶으면 여기 옵션에 체크.
  - 예) EvaluateJsonPath 프로세서에서 생성되는 상태값은 failure, matched, unmatched 가 있음. 여기서 matched할 때만 처리하고 나머지는 별 다른 동작을 안하고 싶으면 해당 상태값 라디오박스 체크한다. 라우팅이 필요한 프로세서에서 유용하게 사용될 수 있음.
### SCHEDULING
- Scheduling Strategy
  - Timer driven: 일정 주기(Run Schedule에 정의된) 로 동작 
  - Event Driven: FlowFiles 해당 프로세서에 공급될 때 동작(실험기능). Concurrent Tasks 0으로 세팅됨. 쓰레드의 수는 관리자가 설정한 Event-Driven Thread Pool 에 의해서 제한됨.
  - CRON driven: 구체적인 스케쥴링 가능. 
    - 값 설정 방법:
      - Number: 여러 값 입력 시 "," 콤마 구분자로해서 입력
      - Range: 숫자-숫자. 대쉬로 연결
      - Increment: 시작숫자/증가값. 슬래쉬로 연결. Minute 0/15 == 0,15,30,45 
      - 그외:
        - *: 와일드카드
        - ?: Days of Month, Days of Week Field에서의 와일드 카드
        - L: Last Day of Month. 1L -> last Sunday of the month
- Concurrent Tasks: 쓰레드 사용 수. 한 프로세서 내에서 동시에 처리할 FlowFiles 수 결정
- Execution: 프로세서 실행될 노드 선택. 프라이버리 노드에서 수행되는 프로세서는 프로세서 아이콘에 "P" 가 붙음.
- Run Duration: 한번 작동할 때 작동되는 시간. 프로세서 작업 끝나면 repository 갱신 (expensive job) -> 한번에 더 많은 일을 처리하고, 업데이트하는 방식으로 throughput 증가시킴. -> 다음작업이 기다리는 시간이 길어짐. (잘 조절해서 사용)
  [처리량향상방안 참고](https://jjaesang.github.io/nifi/2019/02/27/nifi-troble-shooting.html)
### Properties
- 프로세서마다 다름.


### Process Group 설정
#### General
- FlowFile Concurrency: 프로세스 그룹으로 유입되는 데이터에 대한 제어 방안
  - Unbounded: Input Ports 에서 가능한 빨리 데이터 처리
  - Single Flow Per Node: FlowFile이 프로세스 그룹에 들어오면 해당 FlowFile이 나가기 전(Output Port로 나가거나, 시스템/auto-terminated에 의해 제거되거나) 까지 다른 FlowFile 유입안됨.
    - 주의사항:
      - 성능 저하 일으킴 -> 특별한 경우에 사용 (각각의 FlowFile이 다른 프로세서가 한번에 처리해야할 데이터가 있는 경우. 폴더 안의 파일목록 등)
      - 로드밸런싱을 사용하는 경우, 정책에 따라 대기중인 데이터가 다른 노드로 전달될 가능성이 있음. (위와 같은 기능 활용 시에는 로드밸런싱 사용 자제해야함)
  - Single Batch Per Node: Single Flow per Node와 비슷하게 작동하나, Queue 가 비워질 때까지 데이터를 입력함.
- Outbound Policy: 프로세스 그룹에서 반출되는 데이터 흐름 제어 방안
  - Stream When Available: Output Port에 도착하면 바로 반출
  - Batch Output: 모든 데이터가 처리 완료되고 나서 반출. 다중 포트 상황에서 어느 포트에 대기중인지 중요하지 않음. 그룹 내 모든 FlowFile처리 완료가 되야 반출.
    - Sing Flow/Batch Per Node Concurrency 설정과 함께 사용해서 배치 작업 구현 가능 [Batch 성 작업 연결 참고](#batch-작업-연결)
    - 주의사항:
      - FlowFile Concurrency 가 unbounded 인 경우 Batch Output 설정 무시됨.
      - back pressure 고려해야함. 모든 데이터가 처리 될 때까지 데이터는 반출이 안되는 상황에서, 특정 커넥션의 back pressure 제한에 걸리면, 상위 프로세서는 더 이상 작동되지 않음. 프로세서가 완료되지 않으면, 데이터가 나갈 수 없음. 교착상태에 빠짐. -> back pressure 값을 예상되는 범위내에서 최대치로 올리거나, 관련된 모든 커넥션의 back pressure의 값을 0으로 잡아서 제한을 비활성화해야함.
- 
## 설정 이관(재활용)
### 템플릿 export/import
[참고](https://www.projectpro.io/recipes/create-import-and-export-or-download-template-nifi)
- xml 로 추출 후 다른 Nifi instance에 이관 가능
###

### Batch 작업 연결
- 각 프로세스를 프로세스 그룹에 묶어 배치 작업 구현 가능
- 소스 프로세스 그룹 outbound 정책을 batch output으로 설정, 소스와 수신 프로세스 그룹의 FlowFile Concurrency는 Single Flow File/Batch Per Node로 설정
- 위와 같이 설정하면 수신 프로세스 그룹에서는 해당 그룹의 input 대기열이 비어있고, 소스 프로세스 그룹이 모든 데이터를 넘겨줄때까지 데이터를 받아들임.