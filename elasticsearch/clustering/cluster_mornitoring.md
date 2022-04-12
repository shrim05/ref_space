# 클러스터 모니터링
##### 작성: 권영호 (mr.kwon05@gmail.com)
##### last modified: 2021.06.14
##### Elasticsearch version: 7.13
## About
- 클러스터 운영 중 클러스터 상태를 모니터링 하기 위한 API 사용법 정리
- 클러스터 성능 체크 방법 정리
## 모니터링
### health 체크
- 클러스터 레벨 health 체크: _cluster/health API 이용 
- 간단히 사용할 수 있으면서도 빠른 장애 대응이 가능해짐
    ```python
    # req
    GET /_cluster/health
    # response example
    {

    "cluster_name" : "euclid-elk-cluster",
    # green: 클러스터 모든 샤드 정상
    # yellow: 프라이머리 샤드는 정상, 일부 레플리카 샤드 비정상
    # red: 프라이머리 샤드 비정상
    # yellow 상태에서도 서비스 지장은 없으나, 장애 발생 시 즉각적인 복구가 불가능
    "status" : "red",
    # health 체크 API 호출 시 타임아웃 발생여부
    "timed_out" : false,
    # 물리적으로 존재하는 노드 개수
    "number_of_nodes" : 3,
    # 데이터 노드 개수
    "number_of_data_nodes" : 2,
    "active_primary_shards" : 10,
    "active_shards" : 10,
    # 복구를 위해 Relocation 작업 중인 새드 개수. 평상시는 0
    "relocating_shards" : 0,
    # 초기화 진행 중인 샤드 개수. 인덱스 생성 시 잠시동안 초기화 상태 유지. 오랜 시간동안 초기화 진행중이면 문제가 있는거임
    "initializing_shards" : 0,
    # 할당되지 않은 샤드의 개수. 평상시는 대부분 0
    "unassigned_shards" : 1,
    "delayed_unassigned_shards" : 0,
    "number_of_pending_tasks" : 0,
    "number_of_in_flight_fetch" : 0,
    "task_max_waiting_in_queue_millis" : 0,
    "active_shards_percent_as_number" : 90.9090909090909
    }
    ```
- 인덱스 레벨에서의 health 체크: _cluster/health?level=indices API 사용
    ```python
    # request
    GET _cluster/health?level=indices
    # 응답은 생략
    ```
- 샤드 레벨에서의 health 체크: _cluster/health?level=shards API 사용
    ```python
    # request
    GET _cluster/health?level=shards
    # 응답은 생략
    ```

- 특정 인덱스만을 대상으로 요약정보 조회
    ```
    GET /_cluster/health/인덱스명
    # GET /_cluster/health/인덱스명?level=indices or shards 도 가능
    ```

### 물리적인 클러스터 상태 정보 조회
- cluster 레벨 물리 상태 조회
    - 클러스터의 환경설정, 노드 라우팅 방식, 인덱스의 매핑 구성 등
    ```
    GET _cluster/state
    # 노드 레벨의 물리상태 조회
    GET _nodes
    # GET _nodes/_local or ID or IP

    ```
- 통계 검색: 노드 역할,운영체제 정보, 메모리 사용량, CPU 사용량 등
    - 크게 indices 속성, node 속성으로 구성
    ```
    GET _cluster/stats
    # 노드 레벨
    GET _nodes/stats
    ```
### Cat API
- 출력 포맷이 콘솔에 맞게 출력
- 자주 사용하는 파리미터 종류
    - v: 헤더라인
    - help: 헤더라인 상세 설명
    - h: 출력항목 선택
    ```shell
    curl http://localhost:9200/_cat/master?v&h=host,node
    ```
    - format: 출력 포맷 지정 (text, json, smile, yaml, cbor)


## 성능 체크
### API를 활용한 성능 측정
- 통계 지표 획득 API
    ```
    # 노드 통계 조회
    GET _nodes/stats
    
    # 특정 노드 통계 조회
    GET _nodes/{NODE_NAME}/stats
    
    # 특정 노드의 검색 항목만 조회
    GET _nodes{NODE_NAME}/stats/indices/search
    
    # 인덱스 통계 조회
    GET _stats
    
    # 특정 인덱스의 통계 조회
    GET {NODE_NAME}/_stats
    
    # 특정 노드의 Indexing, Refresh, Flush 속성만 조회
    GET _nodes/{NODE_NAME}/stats/indices/indexing,refresh,flush

    # 특정 노드의 HTTP 속성만 조회
    GET _nodes/{NODE_NAME}/stats/http
    
    # 특정 노드의 JVM 속성만 조회
    GET _nodes/{NODE_NAME}/stats/jvm

    # 특정 노드의 query_cache, fielddata 속성만 조회
    GET _nodes/{NODE_NAME}/stats/indices/query_cache,fielddata

    ```

- 검색 성능 측정 지표
    ```python
    # 총 쿼리수
    indices.search.query_total

    # 쿼리에 소요된 총 시간
    indices.search_query_time_in_millis

    # 현재 진행 중인 쿼리수
    indices.search_query_current

    # 총 조회 수
    indices.search.fetch_total

    # 조회에 소요된 총 시간
    indices.search.fetch_time_in_millis

    # 현재 진행 중인 조회 수
    indices.search.fetch_current
    ```

- 색인 성능 측정 지표
    ```
    # 색인된 총 문서수
    indices.indexing.index_total
    # 색인 작업 시 소요된 총 시간
    indices.indexing.index_time_in_millis
    # 현재 색인 중인 문서 수
    indices.indexing.index_current
    # Refresh 작업이 발생한 총 홧수 
    indices.indexing.total
    # Refresh 작업에 소요된 총 시간
    indices.indexing.total_time_in_millis
    # 디스크 flush 작업이 발생한 총 횟수
    indices.flush.total
    # 디스크 flush 작어벵 소요된 총 시간
    indices.flush.total_time_in_millis
    ```
- HTTP 성능 측정 지표
    ```
    # 현재 열려있는 HTTP 연결수
    http.current_open
    # HTTP 연결의 총 개수
    http.total_opened
    ```
- GC(Garbage Collector) 성능 측정 지표
    ```
    # Young 영역의 GC 총 개수
    jvm.gc.collectors.young.collection_count
    # Young 영역의 GC에 소요된 총시간 
    jvm.gc.collectors.young.collection_time_in_millis
    # Old 영역의 GC 총 개수
    jvm.gc.collectors.old.collection_count
    # Old 영역의 GC에 소요된 총시간 
    jvm.gc.collectors.old.collection_time_in_millis
    # 현재 사용중인 JVM 힙의 비유
    jvm.mem.heap_used_percent
    # JVM 힙 커밋 크기
    jvm.mem.heap_committed_in_bytes
    ```

- 캐시 상태 측정
    - 사용자가 직접 생성할 수 있는 fielddata 캐시를 잘못 사용하면 클러스터에 악영향 미침
    - fielddata 캐시는 주로 필드 정렬, 집계 수행 시 사용됨 (힙영역에 생성, 과할 경우 전체적인 성능 하락으로 직결)
    - 가급적 fielddata 사용하지 말 것
    - 성능 측정 지표
    ```
    # 쿼리 캐시 크기
    indices.query_cache.memory_size_in_bytes
    # 생성된 쿼리 캐시 수 
    indices.query_cache.total_count
    # 쿼리 캐시 적중률
    indices.query_cache.hit_count
    # 쿼리 캐시 미스율
    indices.query_cache.miss_count
    # 쿼리 캐시 eviction 회수
    indices.query_cache.evictions
    # 필드데이터 캐시 크기
    indices.fielddata.memory_size_in_bytes
    # 필드데이터 캐시 eviction 회수
    indices.fielddata.evictions
    ```

- 운영체제 성능 측정
    - 엘라스틱서치 API로는 정확한 시스템 성능 측정이 어렵기 때문에 전문적인 툴을 이용할 것
    - 측정필요 지표
        - I/O 리소스 사용률
        - CPU 사용률
        - 송수신된 네트워크 바이트 수
        - 파일 디스크립터 사용률
        - 스왑 메모리 사용률
        - 디스크 사용률


### 랠리를 이용한 부하테스트
- 랠리(Rally): 엘라스틱서치에서 제공하는 성능 측정 벤치마크 툴
- [소개](https://www.elastic.co/kr/blog/announcing-rally-benchmarking-for-elasticsearch), [소스](https://github.com/elastic/rally)
- [샘플 결과 세트](https://elasticsearch-benchmarks.elastic.co/)에서 각 데이터의 특성을 확인해, 운영하게될 데이터와 유사한 데이터를 참고

- 설치
    - 요구사항
        - python >=3.4
        - pip3
        - git >= 1.9
        - JDK >= 8
    ```shell
    # pip install
    pip3 install esrally
    # 최초 환경설정
    esrally configure
    ```
- 사용법
```shell
# 트랙(Track): 부하테스트에 사용할 데이터(색인데이터)
# 랠리 실행 시 --track 옵션으로 원하는 트랙 이름 지정. 미지정시 기본 옵션(geonames 트랙) 사용
esrally list tracks

# 카(Car): 부하테스트에 사용될 노드
# 카 타입은 car, mixin 으로 나뉨. car 와 mixin을 조합해서 원하는 구성의 엘라스틱서치 생성 가능
esrally list cars
# 카 옵션 조합 예시
# 힙크기가 4GB인 엘라스틱서치 실행
--car="4gheap"
# 힙 크기가 4GB인 엘라시특서치 실해앟ㄹ 때 자바 Assertion 기능 활성화
--car="4gheap,ea"
# XPack 보안 설정이 추가된, 힙크기가 4GB인 엘라스틱서치 실행
--car="4gheap,x-pack--security"
# 미선택 시 기본값 : --car="defaults"

# 랠리 시작 명령어
esrally --distribution-version=7.13.1
```
- 부하 테스트 진행 (많은 시간 소요됨) 종료 후 결과 보고서 해석
- 결과보고서는 크게 공통 통계 (전체 데이터를 분석), 단위 업무별 통계로 나뉨
- 다양한 조건에서 수행 각각의 결과보고서 비교 
```
esrally compare --baseline={기준 보고서 시간정보 ex:20210515T111712Z} --contender={비교 대상 보고서 시간정보}
```

### 키바나를 이용한 성능 모니터링
- 키바나 Monitoring 탭 이용
- 대표적인 지표 실시간 제공
- 랠리를 이용한 부하테스트 수행 시 해당 트래픽을 차트에서 확인 가능
- 대표적 지표
    - Search Rate: 전체 샤드에서 실행되는 초당 검색 요청 수 
    - Search Latency: 검색 요청을 처리하기 위한 평균 대기시간
    - Indexing Rate: 모든 샤드에서 인덱싱 처리가 이뤄지고 있는 초당 문서 수
    - Indexing Latency: 인덱싱 처리를 위한 평균 대기시간