## doc info
- 작성자: 권영호 (mr.kwon05@gmail.com)
- 작성일: 2022.03.29

## Install 

### Pyspark
#### 설치환경: Ubuntu 20.04.1 LTS
##### Download install 
- 폐쇄망 설치 환경 고려하여 압축파일 설치로 정리
- [다운로드홈](https://spark.apache.org/downloads.html)
```shell
https://dlcdn.apache.org/spark/spark-3.2.1/spark-3.2.1-bin-hadoop3.2.tgz
tar xzvf spark-3.2.1-bin-hadoop3.2.tgz 
cd spark-3.0.0-bin-hadoop2.7
# 환경변수는 각 환경에 맞게 설정. 여기서는 ~/.bashrc에 지정
export SPARK_HOME=`pwd`
export PYTHONPATH=$(ZIPS=("$SPARK_HOME"/python/lib/*.zip); IFS=:; echo "${ZIPS[*]}"):$PYTHONPATH
```