```shell
sudo yum module enable -y container-tools:rhel8
sudo yum module install -y container-tools:rhel8
#설치
sudo yum -y install podman

# /etc/hosts 권한 변경 *보안문제시 다른 방법 확인
sudo chmod 755 /etc/hosts



```