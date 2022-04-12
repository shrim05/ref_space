## k8s operator for Spark
- [k8s operator for Spark](#k8s-operator-for-spark)
  - [문서정보](#문서정보)
  - [소개](#소개)

### 문서정보
- 작성일: 2022.03.24
- 작성자: 권영호 (mr.kwon05@gmail.com)
### 소개
- 스파크 공식 스케줄러: Stand-alone,Mesos,yarn + k8s
- 스파크 생명주기 관리 방식을 k8s 에 적용하기 위해 k8s 오퍼레이터 사용
  - 스파크, k8s 의 생명주기 관리 방식 확인 필요
  - 스파크: 제출, 상태추적
  - k8s: Deployment, DaemonSet, StatefulSet ..
  - 스파크앱 관리 위해 "최신 트랜드의 오퍼레이터 패턴"을 따른다 => [오퍼레이터패턴](https://kubernetes.io/ko/docs/concepts/extend-kubernetes/operator/) 확인 필요
  