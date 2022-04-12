docker 설치 후
[official_doc](https://docs.docker.com/engine/swarm/)
### docker swarm 시작 (마스터 노드)
$ docker swarm init --advertise-addr [Manager Node IP]

### docker swarm worker join
$ docker swarm join --token TokenKey  master_node_ip:port(2377)
 
**나중에 token값을 확인하는 방법**
```
$ docker swarm join-token worker
```
### Docker Swarm 구성 확인
$ docker node ls 

### 컨테이너간 통신 위한 네트워크 환경 설정
Docker Swarm Cluster의 구성 노드들은 노드 간의 통신을 위해 몇 개의 포트를 사용합니다.

TCP: 2377 (클러스터 관리)
TCP/UDP: 7946 (노드 간 통신)
UDP: 4789 (오버레이 네트워크 트래픽)
모든 서버에서 firewall-cmd 명령을 사용하여 해당되는 포트들을 방화벽에서 예외처리하여 노드 간 통신이 가능하도록 설정합니다.
```
$ firewall-cmd --zone=public --permanent --add-port=2377/tcp
$ firewall-cmd --zone=public --permanent --add-port=7946/tcp
$ firewall-cmd --zone=public --permanent --add-port=7946/udp
$ firewall-cmd --zone=public --permanent --add-port=4789/udp
$ firewall-cmd --reload
```


### swarm 에 서비스 배포
마스터 서버 머신에서 서비스 배포
$ docker service create --replicas 1 --name helloworld alpine ping docker.com
- The docker service create command creates the service.
- The --name flag names the service helloworld.
- The --replicas flag specifies the desired state of 1 running instance.
- The arguments alpine ping docker.com define the service as an Alpine Linux container that executes the command ping docker.com.

### 서비스 작동 확인
```
$ docker service ls
[manager1]$ docker service inspect --pretty helloworld
[manager1]$ docker service ps helloworld

```

### 스케일 변경
```
$ docker service scale <SERVICE-ID>=<NUMBER-OF-TASKS>
```

### 서비스 종료
```
$ docker service scale [servicename]=0 # 운영만 중단
$ docker service rm SERVICE [SERVICE...] # 서비스 삭제
```

### 서비스 중단
```
$ docker service rm helloworld
```