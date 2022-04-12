공식홈페이지 메뉴얼 [출처](https://airflow.apache.org/docs/apache-airflow/stable/installation.html)
# airflow 설치 
## 의존성
- python: 3.6~3.8
- DB: 아래 DB 중 선택
    - PostgreSQL: 9.6, 10, 11, 12, 13
    - MySQL: 5.7, 8 (5.7은 multiple schdulers 작동 안됨, MariaDB는 테스트 안됨.) => 8 버전 이상 사용 권장
    - SQLite: 3.15.0+ (개발용도로만 사용 권장)
## locally install
### quick start 
```
# airflow needs a home, ~/airflow is the default,
# but you can lay foundation somewhere else if you prefer
# (optional)
export AIRFLOW_HOME=~/airflow

AIRFLOW_VERSION=2.0.1
PYTHON_VERSION="$(python --version | cut -d " " -f 2 | cut -d "." -f 1-2)"
# For example: 3.6
CONSTRAINT_URL="https://raw.githubusercontent.com/apache/airflow/constraints-${AIRFLOW_VERSION}/constraints-${PYTHON_VERSION}.txt"
# For example: https://raw.githubusercontent.com/apache/airflow/constraints-2.0.2/constraints-3.6.txt
pip install "apache-airflow==${AIRFLOW_VERSION}" --constraint "${CONSTRAINT_URL}"

# initialize the database
airflow db init

airflow users create \
    --username admin \
    --firstname yh \
    --lastname Kwon \
    --role Admin \
    --email ${email_addr}

# start the web server, default port is 8080
airflow webserver --port 8080

# start the scheduler
# open a new terminal or else run webserver with ``-D`` option to run it as a daemon
airflow scheduler

# visit localhost:8080 in the browser and use the admin account you just
# created to login. Enable the example_bash_operator dag in the home page
```
### 수동설치
#### airflow 설치 
- 설치 시점에 따른 의존 라이브러리 버전 차이 등에서 오는 문제 해결을 위해 설치 시 airflow 버전과 python 버전을 명시해서 해당 버전에서 작동이 확인된 버전으로 설치를 진행하는 편이 좋다
```shell
AIRFLOW_VERSION=2.0.1
PYTHON_VERSION="$(python --version | cut -d " " -f 2 | cut -d "." -f 1-2)"
CONSTRAINT_URL="https://raw.githubusercontent.com/apache/airflow/constraints-${AIRFLOW_VERSION}/constraints-${PYTHON_VERSION}.txt"
pip install "apache-airflow[async,mysql,google]==${AIRFLOW_VERSION}" --constraint "${CONSTRAINT_URL}"
```

### 데이터베이스 연결 [출처](https://airflow.apache.org/docs/apache-airflow/stable/howto/set-up-database.html)
- SQLAlchemy 사용함
- AIRFLOW__CORE__SQL_ALCHEMY_CONN 변수에 database URL 설정

데이터베이스(mysql) 생성
```mysql
CREATE DATABASE airflow_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'airflow_user' IDENTIFIED BY 'airflow_pass';
GRANT ALL PRIVILEGES ON airflow_db.* TO 'airflow_user';
```
데이터베이스(mysql) 관련 세팅
```shell
# my.cnf 파일의 [mysqld] 섹션의 값 설정
explicit_defaults_for_timestamp=1

# airflow sql_alchemy_conn 확인
$ airflow config get-value core sql_alchemy_conn

# airflow sql_alchemy_conn 변경 (default path: ~/airflow/airflow.cfg)
$ vi ~/airflow/airflow.cfg
sql_alchemy_conn = 아래 driver에 맞게 url 설정

# mysqlclient driver 
mysql+mysqldb://<user>:<password>@<host>[:<port>]/<dbname>?charset=utf8mb4
# mysql-connector-python driver
$ airflow config get-value core sql_alchemy_conn
mysql+mysqlconnector://<user>:<password>@<host>[:<port>]/<dbname>?charset=utf8mb4
# charset utf8mb4로 설정하면 airflow setting 값도 설정 필요
sql_engine_collation_for_ids=utf8mb3_general_ci
```
database 세팅 마친 후 airflow 연결
```shell
airflow db init
```
### celery executor 설치
```shell
pip install 'apache-airflow[celery]'
```
### redis 설치
- docker로 redis 설치
```shell
docker pull redis
docker run -d --name redis -p 6379:6379 -v /mnt/c/data_team/source/redis:/data -e REDIS_PASSWORD=airflow redis
pip install apache-airflow[redis]
```

## docker install
- docker-compose file 다운로드
```shell
curl -LfO 'https://airflow.apache.org/docs/apache-airflow/2.0.2/docker-compose.yaml'
```
- 환경 초기화
```shell
mkdir ./dags ./logs ./plugins
echo -e "AIRFLOW_UID=$(id -u)\nAIRFLOW_GID=0" > .env
```
- airflow 초기화
```shell
docker-compose up airflow-init
```
- airflow 나머지 서비스 up
```shell
docker-compose up
```

## 추가 플러그인 설치 시


## trouble shooting
- local 인스톨 도중  Cannot uninstall 'PyYAML' 발생시
```shell
pip install --ignore-installed PyYAML
# 이미 설치된 버전에 의해 라이브러리 버전 충돌 발생할 수 있음
# airflow uninstall 후 다시 설치 진행
pip uninstall "apache-airflow==${AIRFLOW_VERSION}" 
pip install "apache-airflow==${AIRFLOW_VERSION}" --constraint "${CONSTRAINT_URL}"
```

- pymysql 사용 시 no module named 'MySQLdb' 발생
    - 필요 라이브러리 설치 후 result_backend 설정값에 pymysql 추가
    ```shell
    pip install PyMySQL
    ```
    - [how to use pymysql for celery](https://github.com/celery/celery/issues/3503)
    - mysql 대신 postsql 사용 고려 필요