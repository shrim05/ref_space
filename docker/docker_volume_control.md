[official_doc](https://docs.docker.com/storage/volumes/)

## volume 컨테이너를 백업 & 복원하기
### volume 컨테이너 백업
볼륨 컨테이너 확인
```
docker volume ls
```
컨테이너 백업
```
docker run --rm --volumes-from datavolume-name -v $(pwd):/backup image-name tar cvf  backup.tar /path-to-datavolume
```

옵션 설명
* --rm : 컨테이너 생성 후 삭제
* --volumes-from 복제하려는 volume명
* -v 볼륨컨테이너로 생성 
* $(pwd):/backup 현재 로컬 폴더에 새로 만드는 볼륨컨테이너의 backup 폴더를 연결
* image-name tar cvf backup.tar /path-to-datavolume => image-name (새로운 볼륨컨테이너의 베이스 이미지로 백업 대상 컨테이너 내 디렉토리를 (path-to-datavolume)를 backup.tar로 압축)

정리 : $(pwd)에 연결된 새로운 임시 볼륨컨테이너를 생성. 새로운 임시 볼륨컨테이너는 기존 볼륨컨테이너와 연결되어 있기 때문에 압축 명령 실행 시 임시 볼륨컨테이너의 폴더에 백업 파일 생성됨. 생성된 백업파일은 현재 로컬 $(pwd)에 연결되어 있기에 로컬에서 backup file을 확인 할 수 있음.
local.pwd <=> tmp_volume.backup <=> datavolume-name.path-to-datavolume

## volume 컨테이너 복원
```
 docker run --rm --volumes-from datavolume-name -v $(pwd):/backup image-name bash -c "cd /path-to-datavolume && tar xvf /backup/backup.tar --strip 1"
 ```


## 실제 적용 테스트
기존 서버에서 작동 중인 elasticsearch 를 다른 서버에 옮겨봄.

기존에 사용하던 docker-compose.yml 으로 새로운 서버에서 docker container 시작 (volume 컨테이너로 volume 운영 중이었고, 볼륨명 등 동일 설정으로 실행)

```
docker run --rm --volumes-from docker-elk-kor_elasticsearch_1 -v $(pwd):/backup ubuntu tar cvf /backup/elastic_backup.tar /usr/share/elasticsearch/data
```

새로운 서버에 elastic_backup.tar 옮긴 후 복원 시도

```
docker run --rm --volumes-from docker-elk-kor_elasticsearch_1 -v $(pwd):/backup ubuntu bash -c "tar -xvf /backup/elastic_backup.tar --strip 1"
```

하지만 원하는 경로에 압축이 풀리지 않고
압축 시 , 압축 해제 시 적용되는 경로에 대한 이해 부족이 원인

실제 바인드 되어있는 로컬 파일 폴더를 sudo ls 로 뒤져가며 의도한 폴더에 압축을 풀 수 있도록 조정한 결과 성공함.

```
cd usr/share/elasticsearch/data
tar -cvf ../../../../backup.tar .

docker run --rm --volumes-from docker_elk_sociocube_elasticsearch_1 -v $(pwd):/backup ubuntu bash -c "cd /usr/share/elasticsearch/data &&  tar -xvf /backup/elastic_backup_1105.tar --strip 1"

```


## ps
복원 성공은 kibana에서 기존에 만들어놨던 인덱스가 조회되는지를 통해 확인함.

백업 시 사용한 /usr/share/elasticsearch/data 경로는 docker-compose.yml 에서 volume 컨테이너와 바인딩한 경로로서 이 아래 자료를 복원하면 된다고 판단하여 해당 경로 아래 자료만 압축함.

리눅스에서 -C 옵션이 없을 시 압축하고자하는 폴더의 상위폴더도 함께 포함되어 압축되는 점을 몰랐기에 복원시 엉뚱한 경로에 압축이 풀려 헤맸음.

아무튼 경로만 잘 지정해주면 위 백업 방법은 문제없이 적용되는 것 확인 완료.



