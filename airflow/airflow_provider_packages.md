# Provider Packages Guide

- SSH Connection [SSH](#ssh)

## 약어
req : required 변수
opt : Optional 변수
deft : Default 값
## SSH 
[참고](https://airflow.apache.org/docs/apache-airflow-providers-ssh/stable/connections/ssh.html)
### packages
- airflow.providers.ssh.hooks
    - airflow.providers.ssh.hooks.ssh
- airflow.providers.ssh.operators
    - airflow.providers.ssh.operators.ssh
### 사용법
1. SSHHook 구현으로 연결 설정
1. SSHOperator 구현으로 command / 작업 설정
    1.  file 주고 받을 때는 [SFTPOperator](#sftp) 사용
### 환경설정
- Host (req): Remote host ip
- Username (opt)
- password (opt)
- port (opt): deft 22
- extra (opt)
    - key_file - private SSH key file 의 full path
    - private_key - private key content
    - private_key_passphrase - 개인키 암호 해독용 비밀번호
    - timeout - TCP connect timeout(초단위) deft 10
    - compress - deft true. true : traffic 압축
    - no_host_key_check - Set to false to restrict connecting to hosts with either no entries in ~/.ssh/known_hosts (Hosts file) or not present in the host_key extra. This provides maximum protection against trojan horse attacks, but can be troublesome when the /etc/ssh/ssh_known_hosts file is poorly maintained or connections to new hosts are frequently made. This option forces the user to manually add all new hosts. Default is true, ssh will automatically add new host keys to the user known hosts files.
    - allow_host_key_change - Set to true if you want to allow connecting to hosts that has host key changed or when you get 'REMOTE HOST IDENTIFICATION HAS CHANGED' error. This wont protect against Man-In-The-Middle attacks. Other possible solution is to remove the host entry from ~/.ssh/known_hosts file. Default is false.
    - look_for_keys - Set to false if you want to disable searching for discoverable private key files in ~/.ssh/
    - host_key - The base64 encoded ssh-rsa public key of the host, as you would find in the known_hosts file. Specifying this, along with no_host_key_check=False allows you to only make the connection if the public key of the endpoint matches this value.
- 환경설정 샘플
```
{
   "key_file": "/home/airflow/.ssh/id_rsa",
   "timeout": "10",
   "compress": "false",
   "look_for_keys": "false",
   "no_host_key_check": "false",
   "allow_host_key_change": "false",
   "host_key": "AAAHD...YDWwq=="
}
```

## SFTP
### packages
- airflow.providers.sftp.hooks
    - airflow.providers.sftp.hooks.sftp
- airflow.providers.sftp.operators
    - airflow.providers.sftp.operators.sftp
- airflow.providers.sftp.sensors
    - airflow.providers.sftp.sensors.sftp
### 사용법
[공홈](https://airflow.apache.org/docs/apache-airflow-providers-sftp/stable/index.html)
[예시](https://stackoverflow.com/questions/59639285/how-to-define-operations-of-an-stfp-operator-on-airflow)
- 