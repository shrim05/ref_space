## Doc Info
### 작성: 권영호 (mr.kwon05@gmail.com)
### last modified: 2022.03.08


- [Doc Info](#doc-info)
  - [작성: 권영호 (mr.kwon05@gmail.com)](#작성-권영호-mrkwon05gmailcom)
  - [last modified: 2022.03.08](#last-modified-20220308)
- [예제1 (case:TIPA)](#예제1-casetipa)
  - [Oracle to Mysql](#oracle-to-mysql)
  - [query 프로세서](#query-프로세서)
    - [청크사이즈](#청크사이즈)
    - [파라미터 주입](#파라미터-주입)
    - [관계 데이터 동기화](#관계-데이터-동기화)


## 예제1 (case:TIPA)
### Oracle to Mysql
[db연결참고](https://urame.tistory.com/entry/NIFI-PostgreSQL-Connection-%EB%B0%A9%EB%B2%95-ExecuteSQLRecord)
0. ojdbc 설치
  - 다운로드(https://repo1.maven.org/maven2/com/oracle/database/jdbc/ojdbc6/11.2.0.4/)
  - ${nifi_path}/lib/ 아래 파일 이동
  ```shell
  cd ${nifi_path}/lib
  wget https://repo1.maven.org/maven2/com/oracle/database/jdbc/ojdbc6/11.2.0.4/ojdbc6-11.2.0.4.jar
  ```
0. jdbc 설치
  ```shell
  cd ${nifi_path}/lib
  wget https://repo1.maven.org/maven2/mysql/mysql-connector-java/8.0.19/mysql-connector-java-8.0.19.jar
  ```
0. Connection Pool 설정
  - 오른쪽클릭 -> Configure -> Controller services -> 서비스 추가 (+버튼) -> properties 설정 
    - Property 설정 (오라클)
      - Database Connection URL: jdbc:oracle:thin:@ip:port:ORCL
      - Database Driver Class Name: oracle.jdbc.driver.OracleDriver
      - Database Driver Location(s) : ${nifi_path}/lib/ojdbc6-11.2.0.4.jar (ex: /mnt/c/data_team/source/nifi-1.15.3/lib/ojdbc6-11.2.0.4.jar)
      - User/PWD 설정
    - Property 설정 (Mysql)
      - Database Connection URL: jdbc:mysql://ip_address:port/database_name
      - Database Driver Class Name: com.mysql.jdbc.Driver
      - Database Driver Location(s) : ${nifi_path}/lib/mysql-connector-java-8.0.22.zip (ex: /mnt/c/data_team/source/nifi-1.15.3/lib/mysql-connector-java-8.0.19.jar)
      - User/PWD 설정
1. Processor 연결 ([프로세스선택 참고](http://10xthinking.blogspot.com/2019/08/nifi-processors-for-querying-databases.html?m=1))
  - 가장 단순한 연결 QueryDatabaseTable -> PutDAtabaseRecord
    - QueryDatabaseTable Properties 세팅 (이름으로 유추가능한 세팅은 설명 제외함)
      - Database Connection Pooling Service: 위에서 설정한 커넥션 풀 지정
      - Table Name: 데이터베이스(스키마)명까지 명시. (ex CMCOMM_CD가 아닌 SMBA_PMS.CMCOMM_CD), 커넥션 풀에 Database 명시 할 경우 테이블명만으로도 가능할 것으로 보임
      - Maximum-value Columns: 증분여부를 확인할 수 있는 index 컬럼 (순차증가 pk나 업데이트 날짜로 지정)
    - PutDAtabaseRecord Properties 세팅
      - Record Reader: 기본 AvroReader 외 사용 시 추가 설정 필요할 것 으로 보임

0. Input Processor 




### query 프로세서 
#### 청크사이즈

#### 파라미터 주입

#### 관계 데이터 동기화
