# 
1. data 불러오기 -> 데이터 불러오는 건 함수로 정의할 것
1. 데이터 준비
    1. 데이터 정제
        1. data 결측치 확인
            1. df.info() 로 null 데이터 여부 확인
            1. 결측치 0 / 평균 / 중간값 으로 채우거나 , 행/열을 삭제
        1. data 이상치 확인 후 수정 / 삭제 (선택사항)
    1. 특성 선택 (선택사항)
        1. 작업에 유용하지 않은 컬럼 삭제
    1. 특성 공학
        1. 연속 특성 이산화
            - 예시)
        1. 특성 분해하기(범주형, 날짜/시간)
            - 예시)
        1. 특성 변환 (log(x), sqrt(x), x^2 등)
        1. 특성 조합으로 새로운 특성 만들필요 있는지 확인
    1. 특성 스케일 조정 (표준화/정규화)




