### Spider-Engine? [출처](https://rastalion.me/spider-%EC%97%94%EC%A7%84%EC%9D%84-%EC%9D%B4%EC%9A%A9%ED%95%9C-%EC%83%A4%EB%94%A9-%ED%99%98%EA%B2%BD-%EA%B5%AC%EC%B6%95-01/)
- 샤딩 기능이 내장 된 스토리지 엔진
- 파티셔닝 및 [xa 트랜잭션](./xa_transaction.md) 지원
- 다른 MariaDB인스턴스 테이블을 동일한 인스턴스에 있는 것 처럼 처리 가능
- Spider 스토리지 엔진으로 테이블 작성 시 테이블이 원격 서버의 테이블에 링크됨
- remote 테이블은 MariaDB가 지원하는 모든 스토리지 엔진 사용 가능
- 마스터 노드와 스파이더 노드의 연결은 Local MariaDB 노드에서 Remote MariaDB 노드로 연결설정하고, 이 링크는 동일한 트랜잭션을 가진 모든 테이블에 대해 공유되어짐
- 기존 샤딩은 DB 앞단에서 구현 (샤드키 기준 modulo 또는 key 값의 range 활용) -> Spider 엔진 탑재 시 DB 단에서 샤딩 구현 가능
