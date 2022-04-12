# 시험 모듈 환경 정리
## [패키지 리스트 확인 명령어]
```python
import pkg_resources 
import pandas 
OutputDataSet = pandas.DataFrame(sorted([(i.key, i.version) for i in pkg_resources.working_set])) 
print(OutputDataSet)
```
## [패키지 내 함수 및 속성 확인]
- 특정 함수명이나 사용법이 헷갈릴 때 사용할 수 있는 방법
- 예를 들어 sklearn 에서 train test data set 을 나누는 함수가 기억이 안날 때
```python
import inspect
import sklearn
# '__all__', [....,'model_selection',..] 처럼 all 에 있는 모듈을 불러오기 위해 import *
from sklearn import *

# sklearn의 모든 함수,속성 목록 확인
print(inspect.getmembers(sklearn))
# 대충 어디쯤에 있는지는 알아야함.. 모른다면 하나씩 다 뒤져볼 수는 있음..
print(inspect.getmembers(sklearn.model_selection))
# 출력 중에 train_test_split 확인함
# 소스를 확인함으로 작동 방식 확인
print(inspect.getsource(sklearn.model_selection.train_test_split))
# 또는 오픈소스는 doc 정리가 잘 되어 있으니 getdoc을 통해 확인
print(inspect.getdoc(sklearn.model_selection.train_test_split))
```

## [패키지 리스트]
1. beautifulsoup4 4.9.3
    - 웹페이지 크롤링
    - [사용법](https://rednooby.tistory.com/98)
1. matplotlib 3.3.4
1. numpy 1.19.5
1. pandas 1.1.5
1. pillow 8.2.0
    - image처리 라이브러리
    - [사용법](https://neptune.ai/blog/pil-image-tutorial-for-machine-learning)
1. pycrypto 2.6.1
    - 암호화 
    - [사용법](https://info-lab.tistory.com/62)
1. python-dateutil 2.8.1
    - 날짜 핸들링
    - [사용법](https://minimilab.tistory.com/24)
1. pytz 2021.1
    - 세계시간대 
    ```python
    import datetime
    from pytz import timezone
    time_now = datetime.datetime.now(timezone('Asia/Seoul'))
    ```
1. requests 2.18.4
    - http 요청 모듈
    [사용법](https://dgkim5360.tistory.com/entry/python-requests)
1. scikit-learn 0.24.1
1. scipy 1.5.4
1. selenium 3.141.0
    - 크롤링
    - [사용법](https://greeksharifa.github.io/references/2020/10/30/python-selenium-usage/)
1. urllib3 1.22
    - beautfulsoup 사용하면서 익힐 수 있음
1. xgboost 1.4.1
    - 앙상블 모델 (부스팅 모델 속도 개선)
    - [사용법](https://lsjsj92.tistory.com/547)
1. ~~asn1crypto 0.24.0~~
    - 암호관련 직렬화 
1. ~~certifi 2018.1.18~~
    - Python package for providing Mozilla's CA Bundle.
1. ~~chardet 3.0.4~~
    - Character encoding auto-detection in Python 3
1. ~~cmake 3.18.4.post1~~
    - CMake is an open-source, cross-platform family of tools designed to build, test and package software
1. ~~cryptography 2.1.4~~
    -  provides cryptographic recipes and primitives
1. ~~cycler 0.10.0~~
1. ~~cython 0.29.23~~
1. ~~idna 2.6~~
1. ~~joblib 1.0.1~~
1. ~~keyring 10.6.0~~
1. ~~keyrings.alt 3.0~~
1. ~~kiwisolver 1.3.1~~
1. ~~pip 9.0.1~~
1. ~~pygobject 3.26.1~~
1. ~~pyparsing 2.4.7~~
1. ~~python-apt  1.6.5+ubuntu0.5~~
1. ~~pyxdg 0.25~~
1. ~~secretstorage 2.3.1~~
1. ~~setuptools 39.0.1~~
1. ~~six 1.11.0~~
1. ~~soupsieve 2.2.1~~
1. ~~ssh-import-id 5.7~~
1. ~~threadpoolctl 2.1.0~~
1. ~~unattended-upgrades 0.1~~
1. ~~wheel 0.30.0~~