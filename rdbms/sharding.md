## sharding

### 샤딩이란? [출처](https://seokbeomkim.github.io/posts/partition-and-sharding/)
- 큰 데이터를 여러 서브셋으로 나누어 저장하는 기술
- 샤딩 vs 파티셔닝
  - 샤딩: 하나의 큰 데이터를 여러 서브셋으로 나누어 여러 인스턴스에 나누어 저장 (데이터베이스를 여러 개 사용)
    - Horizontal Partitioning 과 샤딩의 차이
      - 수평분할은 스키마가 같은 데이터를 두개 이상의 테이블에 나누어 저장하는 디자인
      - 샤딩은 물리적으로 다른 데이터베이스에 데이터를 수평 분할
        - 경우에 따라 JOIN 등 기능 제약이 있을 수 있고, 일관성, 복제 등에서 불리한 점이 많음
    - 장점: 읽기, 쓰기를 여러 인스턴스로 분산하여 처리 -> 성능, 확장성 이점
    - 단점: 
      - 두개 이상의 샤드에 대한 JOIN 연산 할 수 없음
      - auto increment 등은 샤드 별로 달라질 수 있음
      - shard key column 값은 update 하면 안됨
      - 하나의 트랜잭션에서 두 개 이상의 샤드에 접근할 수 없음
  - 파티셔닝: 하나의 큰 데이터를 여러 서브셋으로 나누어, 하나의 인스턴스의 여러 테이블로 나누어 저장
    - 장점: 
      - 가용성: 물리적인 노드 분리 -> 데이터 손상 가능성 감소
      - 성능: 여러 테이블에 저장 -> 인덱스 크기 감소 -> 인덱스를 통한 조회시간 감소 -> 성능향상 및 메모리 효율 증가
    - 단점: 
      - 테이블 간 join 비용 증가
      - 파티션 제약: 테이블과 인덱스를 별도로 파티션 할 수 없음
### 샤딩 방식
- range 방식
  - 특정 ID 값을 기준으로, ID 범위에 따라 샤드를 나누는 방식
  - ID 값이 증가하는 추이를 보고, 새로운 샤드 추가가 쉽다
  - 디스크 사용량, 쿼리 처리량의 밸런스가 안맞을 수 있다
    - 최근에 추가된 샤드(최근에 추가된 데이터)의 쿼리 처리량이 이전 샤드 처리량보다 많은 경우가 종종 있을 수 있다
- Modulus 방식
  - ID값 % 샤드개수 의 결과값으로 샤드 위치를 결정
  - Range 방식에 비해 리소스 사용 밸런스가 잘 맞음
  - 샤드를 확장하려면, 기존 각 샤드의 데이터를 재배치해야하기 때문에 샤드 추가가 어려운 단점 있음
  - 샤드 개수의 배수로 확장하면, 비교적 쉽게 샤드 추가가 가능함

### 데이터베이스 확장에 대해 [참고](https://betterprogramming.pub/scaling-sql-nosql-databases-1121b24506df)
- 분산환경을 고려하여 만들어진 데이터베이스 활용 (Cassandra, Dynamo 등) => 범위 검색에 취약, JOIN 연산 불가 등 제약이 있음
- RDBMS 샤딩 
- NoSQL vs RDBMS Sharding 