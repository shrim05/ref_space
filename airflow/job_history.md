# Job History
## 설치
- 
- To-Do(2021-05-11~)
    - [x] 기본 개념 정리 
        - [기본사용법](./airflow_usage.md)
        - [주요개념](./airflow_concepts.md)
        - [고급기능]()
    - [x] 튜토리얼 DAG 생성 및 실행 테스트 [result](#tutorial-test-issue-history)
    - [x] SSH Operator [result](#SSH-test-issue-history)
    - [ ] Python Operator [result](#pytho-test-history)
    - [ ] 엘라스틱서치 Operator
    - [ ] mysql Operator
    - [ ] 태스크 연결 작업
    - [ ] 디버깅 방식 테스트
    - [ ] trigger 작동 테스트 [result](#trigger-test)
    - [ ] 환경변수 외부 주입 방법 확인
    
## 사용
- 기본 개념 숙지
    - DAG : 작업흐름명세
    - Operators : DAG 단일 구성 요소 (작업명세)
    - Task: Operators 의 인스턴스화
    - Task instance: DAG, task 및 시점을 특정하는 작업 실행 
        - Task = 워크플로우 실행하기 전, Task instance = 워크플로우가 실행된 것

- Data Pipeline을 구성하고, 정밀한 작업을 위해선 operator를 커스터마이징해서 사용해야 할 듯
    - custom operator 사용법
    - BaseOperator를 상속 받은 operator 커스텀클래스 정의
    [출처](https://airflow.apache.org/docs/apache-airflow/stable/howto/custom-operator.html)
    ```python
    from airflow.models.baseoperator import BaseOperator
    from airflow.utils.decorators import apply_defaults

    class HelloOperator(BaseOperator):

        @apply_defaults
        def __init__(
                self,
                name: str,
                **kwargs) -> None:
            super().__init__(**kwargs)
            self.name = name

        def execute(self, context):
            message = "Hello {}".format(self.name)
            print(message)
            return message
    ```
    
    - 생성한 오퍼레이터 저장 위치 => [import-custom-operator](https://airflow.apache.org/docs/apache-airflow/stable/modules_management.html)

    - Hooks: 외부 API/DB 커뮤니케이션 필요 시 사용 (Task 별로 따로따로 접속하지 않기 위해 사용)
        - [Managing-Connection](https://airflow.apache.org/docs/apache-airflow/stable/howto/connection.html)
        - Web UI 사용
            - Web UI에서 Admin -> Connections 에 접속에 필요한 환경변수(hostname, port, login, password 등) 설정
        - CLI 사용
            - airflow connections add 뒤에 인자로 설정
            ```shell
            airflow connections add 'my_prod_db' \ 
            --conn-uri 'my-conn-type://login:password@host:port/schema?param1=val1&param2=val2'
            ```
        - 
        - Connection 객체의 'conn_id' 를 이용해서 Hooks 설정
## VP Log Job Test
### 계획
- 로컬 pc 에서 4번 서버 vp teamwork server log 매일 불러오기
- log 에서 사용자 및 활동 추출
- 로컬 db / elasticsearch 에 저장
- kibana로 시각화 (간단한 dash보드 구성)

### 작업이력
- 로컬 피시에 airflow 로컬버전으로 구동 (설치 관련 상세 사항 [설치방법](./airflow_install.md) 참고)
    - 로컬 ariflow 사용 시 airlfow config 에 대한 경로가 실행 위치마다 다르게 설정되어 있는 문제가 있음
        - 주피터노트북에서 테스트 시 ssh connection id 못 읽어옴 => 기본 AIRFLOW_HOME 설정이 다름을 확인
        - 기본 AIRFLOW_HOME = ~/airflow
        - WSL 주피터에서 실행 시  AIRFLOW_HOME = /home/username/airflow
        - 실제 설정되어야할 경로  AIRFLOW_HOME = /mnt/c/path_I_intended/airflow
        => 가상환경 제대로 지정 시 문제 해결

    - docker로 실행환경 변경해서 환경설정에 대한 제어 통일성 가져오는걸로 방향 전환 검토
        - docker로 설치 및 실행 했을 경우, 실행은 문제 없으나 코드 작동 테스트 환경을 따로 갖추어야함
           - vscode attach container로 진행하려고 했으나, vscode 사용에 필요한 폴더 생성 권한 문제 생김
                - 다양한 해결 방법이 있으나 번거로움.. [adding-non-root-user](https://code.visualstudio.com/docs/remote/containers-advanced#_adding-a-nonroot-user-to-your-dev-container)
            - jupyter notebook으로 코드 작동 여부 테스트
            => 로컬환경에서 개발/테스트 먼저 진행
    - 
- SSHHook 통해 4번 서버 vp log 가져오기 테스트 
    - SSH 로 직접 읽어서 가져오는 방법 
    - vp log를 엘라스틱서치에 연결해서 엘라스틱서치를 공통 접근 db로 사용하는 방법


### Tutorial Test Issue History
    1. DAG 튜토리얼 코드 생성 후 celery scheduler exception 발생
        - result_backend 표기 오류
        - redis 미설치 오류
        - sql_alchemy 에서 mySQLdb 모듈 못찾는 문제(install에 해결법 기록)
    1. hello_task 출력 안됨
        - celery executor 작동원리 파악 필요
            - Worker Process까지 task 전달이 안된걸로 보임
    1. CeleryExecutor => SequentialExecutor 로 변경해서 테스트 진행
    1. 가동 확인
        - DAG 설정 및 선언 -> scheduler 가동 -> worker DAGs Run

### SSH Test Issue History
    1. web-ui 통해서 connection 생성 후 hook 객체에 connection_id 할당 후 SSHOperator에 hook 연결하여 사용
    1. ssh_default connection으로 hook 객체에 user_id 및 password 동적할당 후 사용 방법 테스트
        - id_rsa 개인키 경로 설정 후 사용 가능 테스트 완료
    1. [SSHOperator 사용법](./airflow_provider_pacakges.md)

### Python Test History
    1. py 파일 내 외부라이브러리 사용하여 데이터 처리 후 db 저장 로직 테스트
    1. 데이터 처리 후 저장을 다른 task 로 넣을지, 한 task에서 모두 처리할 지 확인
    1. best practice example 확인
    1. 

### Trigger Test
    1. 단어사전 변경 후 tokenizer 용어 사전 변경