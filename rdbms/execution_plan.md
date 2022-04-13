## 실행계획
[출처](https://coding-factory.tistory.com/744)
### 실행계획이란? 
- 사용자가 SQL을 실행하여 데이터를 추출하려고 할 때 옵티마이저가 수립하는 작업 절차

### 실행 계획 확인하는 방법 (오라클 기준) [출처](https://coding-factory.tistory.com/745)
- EXPLAIN PLAN: 
```SQL
-- 사용 예시
EXPLAIN PLAN -- EXPLANIN  PLAN 선언부
SET STATEMENT_ID = 'PLAN1' INTO PLAN_TABLE -- SQL에 PLAN1이라는 ID 부여
FOR
SELECT * FROM REGIONS A --SQL 입력부
LEFT OUTER JOIN COUNTRIES B ON A.REGION_ID = B.REGION_ID;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY -- PLAN_TABLE에 저장된 실행계획 조회
('PLAN_TABLE','PLAN1','ALL'));
```
- 쿼리문의 실행 계획을 PLAN_TABLE에 저장한 후 직접 조회하거나, DBMS_XPLAN 패키지 사용하여 조회
- 실행 계획만 생성, 실제 데이터 처리하지 않기 때문에 데이터베이스에 부하 없음
- 단점:
  - 한번에 하나의 실행계획만 확인 가능 
  - 실행계획 확인하기 위해 별도의 SELECT 문 작성해야하는 번거로움
  - 데이터를 읽지 않기 때문에 소요시간 추정, 데이터 관련 I/O 정보 확인 할 수 없음
- PLAN_TABLE 구조
    - STATEMENT_ID:	EXPLAIN PLAN 명령을 수행할 떄 사용자가 정의한 ID
    - PLAN_ID:	데이터베이스 내에서 실행 계획이 갖게 되는 단일 속성
    - TIMESTAMP: EXPLAIN PLAN 명령을 수행한 날짜, 시간 정보
    - REMARKS:	EXPLAIN PLAN 명령을 수행할 떄 사용자가 임의로 넣는 주석
    - OPERATION:	INSERT, SELECT, UPDATE, DELETE 가운데 하나가 수행될 때 단계 별 작동형태를 정의
    - OPTIONS:	OPERATION의 상세 옵션을 설명
    - OBJECT_NODE:	참조하는 객체의 데이터베이스 링크 이름
    - OBJECT_OWNER:	테이블 또는 인덱스의 소유주
    - OBJECT_NAME:	테이블 또는 인덱스의 이름
    - OBJECT_ALIAS:	SQL에서 정의된 테이블 또는 뷰의 유일한 별칭
    - OBJECT_INSTANCE:	FROM절에 기술된 객체에 부여하는 번호
    - OJBECT_TYPE:	객체의 유형
    - OPTIMIZER:	옵티마이저 모드 정보
    - ID:	수립된 각 실행 단계의 일련번호
    - PARENT_ID:	ID에 해당하는 부모 ID
    - POSITION:	동일 PARENT_ID를 가지는 ID 사이의 처리 순서
    - COST:	각 처리 단계별 비용
    - CARDINALITY:	명령 수행으로 인해 접근하게 될 행 수의 쿼리 최적화 방법에 의한 예측값
    - BYTES:	명령 수행으로 인해 접근하게 될 바이트 수의 쿼리 최적화 방법에 의한 예측값
- SET AUTOTRACE, SQL TRACE는 출처 확인

### 실행계획 해석 방법 (상세 설명 출처 확인)
1. 위에서 아래로 읽어 내려가면서 제일 먼저 읽을 스텝을 찾습니다.
2. 내려가는 과정에서 같은 들여 쓰기가 존재한다면 무조건 위 -> 아래 순으로 읽습니다.
3. 읽고자 하는 스텝보다 들여 쓰기가 된 하위스텝이 존재한다면, 가장 안쪽으로 들여쓰기 된 스텝을 시작으로 하여 한 단계씩 상위 스텝으로 읽어 나옵니다.

### SCAN의 종류와 속도
- FULL TABLE SCAN: 테이블 전체 데이터를 읽어 조건에 맞는 데이터를 추출하는 방식
  - FULL TABLE SCAN을 해야하는 상황
    - 조건절에서 비교한 칼럼에 인덱스가 없는 경우
    - 조건절에서 비교한 컬럼에 최적화된 인덱스는 있지만, 조건에 만족하는 데이터가 테이블의 많은 양을 차지하여 FULL TABLE SCAN이 낫다고 옵티마이저가 판단하는 경우
    - 인덱스는 있으나, 테이블의 데이터 자체가 적어  FULL TABLE SCAN이 낫다고 옵티마이저가 판단하는 상황
    - 테이블 생성 시 DEGREE 속성 값이 크게 설정되어 있는 경우 
    - 인덱스 생성 시, 조회 성능 향상됨 하지만 update , delete 성능 낮아짐
- ROWID SCAN: ROWID를 기준으로 데이터를 추출. 단일행에 접근하는 방식 중 가장 빠름
  - ROWID SCAN을 타는 상황
    - 조건절에 ROWID를 명시한 경우
    - INDEX SCAN을 통해 ROWID를 추출한 후 테이블에 접근할 경우
- INDEX SCAN: 인덱스 활용 데이터 추출
  - INDEX SCAN을 타는 상황
    - INDEX UNIQUE SCAN:	UNIQUE INDEX를 구성하는 모든 컬럼이 조건에 "="로 명시된 경우
    - INDEX RANGE SCAN	
      1. UNIQUE 성격의 결합 인덱스의 선두 컬럼이 WHERE절에 사용되는 경우
      2. 일반 인덱스의 컬럼이 WHERE절에 존재하는 경우
    - INDEX RANGE SCAN DESCENDING:	INDEX RANGE SCAN을 수행함과 동시에 ORDER BY DESC절을 만족하는 경우
    - INDEX SKIP SCAN:	
      1. 결합 인덱스의 선행 컬럼이 WHERE절인 경우
      2. 옵티마이저가 INDEX SKIP SCAN이 FULL TABLE SCAN보다 낫다고 판단하는 경우 
    - INDEX FULL SCAN:	
      1. ORDER BY / GROUP BY의 모든 컬럼이 인덱스의 전체 또는 일부로 정의된 경우
      2. 정렬이 필요한 명령에서 INDEX ENTRY를 순차적으로 읽는 방식으로 처리된 경우
    - INDEX FULL SCAN DESCENDING:	INDEX FULL SCAN을 수행함과 동시에 ORDER BY DESC절을 만족하는 경우
    - INDEX FAST FULL SCAN:	FULL TABLE SCAN을 하지 않고도 INDEX FAST FULL SCAN으로 원하는 데이터를 추출할 수 있고, 추출된 데이터의 정렬이 필요 없으며, 결합 인덱스를 구성하는 컬럼 중에 최소 한개 이상은 NOT NULL인 경우 
    - INDEX JOIN:	추출하고자 하는 데이터가 조인하는 인덱스에 모두 포함되어 있고 추출하는 데이터의 정렬이 필요없는 경우