## k8s install on local
- [k8s install on local](#k8s-install-on-local)
  - [문서정보](#문서정보)
    - [setup [Debian]](#setup-debian)
    - [minikube vs kind](#minikube-vs-kind)
    - [setup kind](#setup-kind)

### 문서정보
- 작성일: 2022.04.11
- 작성자: 권영호 (mr.kwon05@gmail.com)

#### setup [Debian]
[공식홈](https://kubernetes.io/ko/docs/tasks/tools/install-kubectl-linux/)
```shell
# apt 패키지 색인을 업데이트하고 쿠버네티스 apt 리포지터리를 사용하는 데 필요한 패키지들을 설치한다.
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl
# 구글 클라우드 공개 사이닝 키를 다운로드한다.
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
# 쿠버네티스 apt 리포지터리를 추가한다.
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
# 새 리포지터리의 apt 패키지 색인을 업데이트하고 kubectl을 설치한다.
sudo apt-get update
sudo apt-get install -y kubectl

# bash 자동 완성 스크립트 설치
sudo apt-get install bash-completion
kubectl completion bash
# bash-completion 설치 확인
type _init_completion

# kubectl 자동완성 활성화
echo 'source <(kubectl completion bash)' >>~/.bashrc
```

#### minikube vs kind
- 로컬 개발환경에서 쿠버네티스를 실행하기 위해 minikube 또는 kind를 사용하여 단일노드 쿠버네티스 클러스터를 구성할 수 있다.
- minikube
  - VM 를 생성하는 방식
  - 여러 하이퍼바이저 지원 -> 주요 운영체제에서 사용 가능
  - 여러 인스턴스를 병렬로 생성할 수 있음
  - 제공되는 대시보드를 통해 클러스터 상황 확인 가능
- kind
  - 도커 컨테이너를 사용하는 방식
  - VM 방식보다 시작 속도가 빠름
  - 로컬 이미지를 클러스터에 직접 로드할 수 있음 => kind load docker-image my-app:latest 명령어로 이미지를 쉽게 k8s 클러스터에서 사용

- 도커 방식이 익숙하므로 kind로 진행함

#### setup kind
- 설치
```shell
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.12.0/kind-linux-amd64
chmod +x ./kind
# 폴더 이동 시 
mv ./kind /some-dir-in-your-PATH/kind
```
- 클러스터 셋업
```shell
# 클러스터 생성
./kind create cluster

# 클러스터 확인 
kubectl cluster-info
```