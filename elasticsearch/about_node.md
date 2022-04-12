### 노드란?
- 물리적으로 실행된 런타임 상태의 엘라스틱서치
- 노드 종류(역할별. 한 노드에서 여러 역할 담당 가능)
- 노드를 설정하는 방법은 $ES_HOME/config/elasticsearch.yml 파일안에 node.roles: [역할이름1,역할이름2,..] 로 설정
    - master(Master-eligible node): 클러스터 제어담당
        - 주 역할: 인덱스 생성, 삭제, 노드 추적, 샤드 할당
        - 구체적으로는 Dedicated master-eligible 노드와 Voting-only master-eligible 노드로 구분됨
            - Dedicated Master-eligible node: 다른 역할을 갖지 않고, 클러스터 관리에만 집중하는 노드
                - master-eligible node는 Coordinating node 역할(클라이언트 요청을 다른 노드에 route하는 역할의 노드)을 할 수 있지만, dedeicated master node는 해당 역할을 수행하지 않는걸 권장함
                ```yml
                node.roles: [master]
                ```
            - Voting-only master-eligible node: 마스터 노드 선출 과정에 참여하지만, 실제 마스터 노드로는 선출되지 않는 노드. (마스터 노드 선출 과정에서 동점 상황을 해결하기 위한 역할)
            - 마스터로 선출되지 않을 뿐 클러스터 상태를 publishcations 할 때 특정 작업을 수행하고, 마스터와 동일한 책임을 지니고 있음.
            - 아직 정확히 이 노드가 왜 필요한지 알 수 없었음.(마스터 노드 선출과정을 자세히 알아봐야함)
                ```yml
                node.roles: [ data, master, voting_only ]
                ```

        - 고가용성 클러스터 구성을 위해선 최소 3개(홀수개로 구성. split brain 방지)의 masger-eligible 노드가 필요함 (voting-only 는 포함안됨)
    - data: 데이터 저장, CRUD, 검색, 집계 등 데이터 관련 작업
        ```yml
        node.roles: [ data ]
        ```
    - data_content: 사용자가 만드는 content 전용 node
        ```yml
        node.roles: [ data_content ]
        ```
    - 사용빈도에 따라 노드를 구분할 수 있음 (로그 등 시계열 데이터 처리에 적합)
        - data_hot: 사용빈도가 높은 시계열 데이터 저장. (빠른 접근/처리)
            ```yml
            node.roles: [ data_hot ]
            ```
        - data_warm: 
            ```yml
            node.roles: [ data_warm ]
            ```
        - data_cold
            ```yml
            node.roles: [ data_cold ]
            ```
        - data_frozen
            ```yml
            node.roles: [ data_frozen ]
            ```
    - ingest: 색인(Indexing) 전 전처리 작업 담당 (리소스 사용이 많기 때문에, data,master 노드와 함께 사용 비추천)
        - 전처리에 많은 리소스가 사용될 경우 사용
            ```yml
            node.roles: [ ingest ]
            ```
        
    - Coordinating only: route requests, 검색 reduce 단계 처리, 벌크 indexing 분배, 로드밸런서
        - 너무 많은 coordinating only 노드 운영은 전체 클러스터 성능에 부담을 줌(선출된 마스터 노드가 모든 노드들의 상태를 확인을 위해 기다려야 하기때문에)
        - 데이터 노드에서도 같은 역할을 충분히 할 수 있음
        ```yml
        node.roles: [ ]
        ```
    - remote_cluster_client: cross-cluster client 역할. 
        - cross cluster 환경에서 사용
        ```yml
        node.roles: [ remote_cluster_client ]
        ```
    - ml: (xpack 기능) 머신러닝 api 요청 처리 및 job 실행
        - 사용하려면 xpack.ml.enabled 설정 true 가 모든 coordinating 역할하는 노드에 설정되어야 함
        ```yml
        node.roles: [ ml ]
        xpack.ml.enabled: true
        # corss cluster 환경내에서는 remote_cluster_client 역할 추가 추천(모든 master-eligible-nodes 에도 remote_cluster_client 역할 설정해야함)
        # node.roles: [ ml, remote_cluster_client ]
        ```

    - transform: (xpack 기능) transform API request 담당
        - 데이터를 피벗 등 형태로 변환
        ```yml
        node.roles: [ transform, remote_cluster_client ] 
        ```
### 노드 역할 바꾸는 법 (repurposing a node)
- elasticsearch.yml 에서 role 을 변경 후 아래 추가 작업진행
- 데이터 노드 -> 다른 노드 역할로 변경 시
    - allocation filter 사용 (shard 데이터를 안전하게 클러스터 내 다른 노드로 옮기는 작업)
- data/master 노드 외 노드 -> 다른 노드 역할
    - 비어있는 data path에서 새 역할로 시작 (data path를 새로 지정하거나, 기존 data path내 데이터를 지우면됨)
- 위 과정을 할 수 없는 상황이면 elasticsearch-node repurpose 를 실행하면 됨
- data/master 노드에서는 아래와 같은 정보를 다루기 때문에 node 역할 변경 시 데이터에 대한 처리도 해줘야하는 것임
    - data 노드 관리 데이터
        - shard data, 노드에 할당된 shard 와 관련된 index metadata, cluster-wide metadata (settings, index templates)
    - master-eligible 노드 관리 데이터
        - 클래서터 내 모든 index metadata, cluster-wide metadata(settings, index templates)
    - 노드는 시작 시 data path에 있는 내용물을 확인함 -> 디스커버리 시 역할에 맞지 않는 데이터를 찾으면 시작이 안됨 (즉, 데이터 노드는 shard 데이터를 찾지 못하면 시작이 안됨)
