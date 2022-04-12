## Doc Info
### 작성: 권영호 (mr.kwon05@gmail.com)
### last modified: 2022.03.16

- [Doc Info](#doc-info)
  - [작성: 권영호 (mr.kwon05@gmail.com)](#작성-권영호-mrkwon05gmailcom)
  - [last modified: 2022.03.16](#last-modified-20220316)
- [QueryDatabaseTable](#querydatabasetable)
  - [특징](#특징)
  - [속성](#속성)
- [QueryDatabaseTableRecord](#querydatabasetablerecord)
- [GenerateTableFetch](#generatetablefetch)

## QueryDatabaseTable
### 특징
  - SQL select query 생성 후 실행 (Maximum-value Columns 설정 시 해당 컬럼값 기준으로) -> 기준 만족하는 모든 rows fetch -> Avro Format으로 변환
  - incoming 커넥션 허용안됨 (항상 시작 프로세스여야함)
  - 표현식을 사용하는 속성에 Variable Registry 사용 가능
  - FlowFile의 속성을 사용하여 쿼리 수행 원할 시에는 GenerateTableFetch-ExecuteSQL 조합 사용
  - 프라이머리 노드에서만 동작함
  - FlowFile의 querydbtable.row.count로 행 수 알 수 있음
### 속성
  - **표시: 표현식 사용가능한 속성
  - **Table Name: 테이블명. 커스텀 쿼리 사용 시 쿼리의 alias로 사용되며, FlowFile의 속성으로 잡힘 
  - **Columns to Return: 콤마분할 기재. 컬럼명에 quoting 등 특수작업 필요 시 기재. 공백일 경우 모든 컬럼.
  - **Additional WHERE clause: 조건절 추가. 표현식 사용 시 variable registry에 있는 변수만 사용 가능
  - **Custom Query: 커스텀 쿼리. 해당 쿼리는 sub-query로 묶임. ORDER BY 절 사용 불가.
  - **Maximum-value Columns: 
    - 컬럼이름들 콤마분할 기재. 기재한 컬럼의 최대값을 추적. 기재한 순서대로 정렬 우선순위 가짐. 앞에 기재한 컬럼이 뒤에 기재한 컬럼보다 느리게 값이 증가할 것으로 기대함. -> 여러 컬럼들을 사용하는건 테이블 파티셔닝에 사용되는 것과 같이 컬럼들의 계층구조를 의미함.
    - 마지막 검색 이 후 추가/업데이트된 행만 검색하는 데 사용 가능
    - 몇몇 JDBC 환경에서는 bit/boolean 값은 해당 속성값으로 적절하지 않음. (에러발생함 - 해당 속성 컬럼들을 사용하지 말 것)
    - 값이 없으면 모든 컬럼들을 고려함 -> 성능 이슈 생김
  - **Max Wait Time: Select 쿼리 수행 시 최대 대기 시간. 1초 미만은 0으로 간주. 0 -> no limit
  - **Fetch Size: 한번에 result set에서 가져올 result rows 수. 데이터베이스 드라이버의 힌트이며, 정확하지 않을 수 있음. 값이 0 이면 힌트 무시.
  - **Max Rows Per Flow File: 하나의 FlowFile에 담을 result rows 수. 큰 result sets 여러개의 FlowFile로 나누는데 사용. 값이 0 이면 모든 rows 가 한개의 FlowFile로 전환.
  - **Output Batch Size: 프로세스 세션을 커밋하기 전 (확실하진 않으나 해당 세션을 Provenance Repository에 기록하기 전이란 뜻 같음) Queue(대기열)에 담을 Output FlowFiles 수. 
  - **Maximum Number of Fragments: 
    - fragments 최대 개수. 0 이면 모든 fragments 반환
    - 대용량 테이블 처리 시 OOM(OutOfMemory) 방지에 사용 가능.
    - 데이터 손실 가능성이 있음. -> 값 설정 시, incoming 순서가 보장되지 않고, result set 에 행이 포함되지 않는 경계에서 fragment가 끝날 수 있음.
    - 좀 더 자세한 사례를 찾아봐야함
  - Normalize Table/Column Names: Avro에서 지원되지 않는 테이블명,컬럼명 글자를 변환할지 여부. 예) 콜론(:), 온점(.)은 언더바(_)로 변경됨.
  - 
## QueryDatabaseTableRecord
- QueryDatabaseTable 와 같은 작동 방식이나 쿼리 결과를 지정한 형식으로 변환할 수 있음 (RecordWriter 속성에 지정)


## GenerateTableFetch