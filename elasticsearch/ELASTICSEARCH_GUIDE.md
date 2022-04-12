[참고](https://esbook.kimjmin.net/)
[공식레퍼런스](https://www.elastic.co/guide/en/elasticsearch/reference/index.html)

file to bulk api
bulk.json to elastic
```
$ curl -XPOST "http://localhost:9200/_bulk" -H 'Content-Type: application/json' --data-binary @bulk.json
```


### elasticsearch python api 사용법

- global options 
    - Ignore : 에러 발생 시 무시(예외 발생 안함)
    ```python
    from elasticsearch import Elasticsearch
    es = Elasticsearch()

    # ignore 400 cause by IndexAlreadyExistsException when creating an index
    es.indices.create(index='test-index', ignore=400)

    # ignore 404 and 400
    es.indices.delete(index='test-index', ignore=[400, 404])
    ```    
    - Timeout 
        - client 생성 시 또는 request 단위로 설정 가능. 
        - API 호출 시 timeout 인자값 설정하여도 정확히 설정한 시간에 request가 종료되는걸 보장하지는 않음
    
    
    - Request 추적 : opaque_id 설정하여 로그 확인 가능
        - deprecation logs , slow log origin, identifying running tasks 등 확인 가능

    ```python
    from elasticsearch import Elasticsearch
    client = Elasticsearch()
    # You can apply X-Opaque-Id in any API request via 'opaque_id':
    resp = client.get(index="test", id="1", opaque_id="request-1")
    ```
    - Response Filtering
        - filter_path 인자로 결과값 필터링 가능
        ```python
        es.search(index='test-index', filter_path=['hits.hits._id', 'hits.hits._type'])
        es.search(index='test-index', filter_path=['hits.hits._*'])
        ```


### query 기본

- query context : 해당 document가 query 절과 얼마나 잘 일치하는가에 대한 응답 (일치정도를 _score로 표현)
- filter context : 해당 document가 query 절과 일치하는가에 대한 응답. score 계산 안함. true, false 로 표현

- bool 쿼리 종류
    - must : 지정된 모든 쿼리가 일치하는 document 조회
    - should : 지정된 모든 쿼리가 하나라도 일치하는 document 조회
    - must_not : 모든 쿼리가 모두 일치하지 않는 document 조회
    - filter: must와 동일 but score 무시

bool 쿼리 내에 위의 각 절들을 조합해서 사용할 수도 있고, 또한 bool 절 내에 bool 쿼리를 작성할 수도 있음.

#### 예제1)
```
1) title 필드에 전동식 있고
2) text 필드에 조립방법 있고
3) ipc 필드의 값이 정확히 B62D 5/04(2006.01.01) F16H 25/22(2006.01.01) 이고
4) publish_date 필드의 값이 정확히 2015.01.01 이후인 경우
{
  "query": { 
    "bool": {
      "must": [
        { "match": { "title":   "전동식" }}, 
        { "match": { "text": "조립방법" }}  
      ],
      "filter": [ 
        { "term":  { "ipc": "B62D 5/04(2006.01.01) F16H 25/22(2006.01.01)" }}, 
        { "range": { "date": { "gte": "2015.01.01" }}} 
      ]
    }
  }
}
```

[쿼리실행](./query_example.es)

- range 종류
    - gte, gt, lte, lt, boost(scoring 계산 시 가중치 부여. 기본값 1.0 (대략적 n 값은 n배 가중치))

- term : 역색인에 명시된 토큰 중 정확한 키워드 가 포함된 문서 조회
- terms : 배열에 나열된 키워드 중 하나와 일치하는 문서 조회


#### 예제)
```
{
  "query": {
    "bool": {
      "minimum_should_match": 1, #should 조건에서 최소 1개 이상 일치할 것
      "should": [
        {
          "term": {
            "title": "자바"
           }
        },
        {
          "term": {
            "title": "컴퓨터"
          }
        },
        {
          "term": {
            "title":  "스크립트"
          }
        }
      ],
      "must": [
          {
            "wildcard": {
                "ipc": {
                    "value": "*B65G*" #ipc 는 B65G를 포함하고 있어야함(와일드 카드 사용)
                }
            }
        }
      ]
    }
  },
  "highlight": {
    "fields": {
      "title": {} #title에서 검색 결과 일치 부분 강조
    }
  }
}
```

[쿼리실행](./query_example.es)

#### 예제
multi_match : 
```
{
    "size": 3, #결과에서 3개만 반환
    "query": {
        "multi_match": {
            "query": "스마트폰 자율주행", 
            "fields":
                ["title^3","text"] #타이틀에 boost 3.0 적용
        }   
    }
}

```

[스코어링](https://kazaana2009.tistory.com/6)

### bulk mvectors



#### massive search 예제
[공식 bulk-api 양식](https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-bulk.html#docs-bulk)
[python-api](https://stackoverflow.com/questions/28546253/how-to-create-request-body-for-python-elasticsearch-msearch)
```python
_index = 'corpus_patent2'
request = []

req_head = {'index': _index}
req_body = {'_source':[''],'query': {"bool": {"should":[{"term": {"title": "test"}},{"term": {"text": "test"}}],"must": [{"term": {"ipc": "t123"}}]}}}
request.extend([req_head, req_body])

req_head = {'index': _index}
req_body = {'query': {"bool": {"should":[{"term": {"title": "test"}},{"term": {"text": "test"}}],"must": [{"term": {"ipc": "t234"}}]}}}
request.extend([req_head, req_body])

req_head = {'index': _index}
req_body = {'query': {"bool": {"should":[{"term": {"title": "test"}},{"term": {"text": "test"}}],"must": [{"term": {"ipc": "t13"}}]}}}          
request.extend([req_head, req_body])
resp = es.msearch(body = request)
```



### 많은 양의 데이터를 불러올때(기본 max_size 10000 이상)
- search api로 불러올 수 있는 문서 제한은 10000 (최대 50000까지 설정가능)
- 성능 문제로 문서 제한을 늘리는 건 테스트를 통해 결정해야함
- elasticsearch 의 scroll api 나 es-python 의 scan api를 통해 제한 이상의 문서를 가져올 수 있음 (scan return type generator)
- scan을 사용하는 경우 score 계산이 안됨
[Elastic search not giving data with big number for page size](https://stackoverflow.com/questions/49320599/elastic-search-not-giving-data-with-big-number-for-page-size/49321145#49321145)
```python
helpers.scan(es,
    query={"query": {"match": {"title": "python"}}},
    index="orders-*",
    doc_type="books"
)
```
전체 문서를 dataframe으로 만드는 예시
```python
from elasticsearch import Elasticsearch, helpers
import pandas as pd

#엘라스틱서치 접근 객체
es =  Elasticsearch(host='localhost', port='9200')   

#scan
def get_all_docs(_index,fields):
    res = helpers.scan(es, index=_index, query={"_source" : fields, "query" : {"match_all": {} } })
    return res

# 제너레이터 reader 
class GeneratorReader(object):
    def __init__(self, g):
        self.g = g
    
    def gen_es_source(self):
        source_list = []
        try:
            for res in self.g:
                source = res['_source']
                source_list.append(source)
            return source_list
        except StopIteration:
            return ''
        
    def read_es_source(self):
        try:
            es_result = next(self.g)
            source = es_result['_source']
            return source
        except StopIteration:
            return ''
    
    def read(self, n=0):
        try:
            return next(self.g)
        except StopIteration:
            return ''

res = get_all_docs(_index='corpus_patent', fields=["doc_id","title","text","ipc"])
df = pd.DataFrame(GeneratorReader(res).gen_es_source())
```


#### statistics
!중요: statistics 집계는 인덱스 기준이 아닌 shards 기준으로 집계
[참고](https://discuss.elastic.co/t/what-does-doccount-and-docfreq-mean-in-the-explain-api/163850)
- field statistics
Setting field_statistics to false (default is true) will omit 

document count (how many documents contain this field): 얼마나 많은 문서가 해당 필드를 갖고 있는가

sum of document frequencies (the sum of document frequencies for all terms in this field)
: 해당 필드 내 모든 용어의 문서 수의 합계

sum of total term frequencies (the sum of total term frequencies of each term in this field)


- Term statistics
Setting term_statistics to true (default is false) will return

total term frequency (how often a term occurs in all documents) : 전체 문서에서 해당 용어의 빈도수
document frequency (the number of documents containing the current term) : 해당 용어를 갖고 있는 문서의 수
By default these values are not returned since term statistics can have a serious performance impact.

```
index = 'corpus_patent'
전체문서수: 39952

'term_vectors': {'text': {'field_statistics': {'sum_doc_freq': 1709962,
      'doc_count': 47951,
      'sum_ttf': 2963961},
  'terms': {'경우': {'doc_freq': 1853,
        'ttf': 2712,
        'term_freq': 1,
        'tokens': [{'position': 33, 'start_offset': 77, 'end_offset': 79}]}
  }

'경우': {'doc_freq': 1853,
       'ttf': 2712,
       'term_freq': 4,
       'tokens': [{'position': 53, 'start_offset': 180, 'end_offset': 182},
        {'position': 100, 'start_offset': 357, 'end_offset': 359},
        {'position': 125, 'start_offset': 459, 'end_offset': 461},
        {'position': 160, 'start_offset': 574, 'end_offset': 576}]},
```

#### decompound mode
사용자사전:
hs
품목분류
hs품목분류 hs 품목분류

원문(A200928002490_1):
본 발명은 무역관세 전문 분야인 HS 품목분류를 인공지능 기술을 통해 자동으로 정확히 처리해서 관세 관련 전문가는 물론 비전문가도 무역 관세 및 HS 품목분류 작업을 수행할 수 있게 하는 인공지능 기계학습 기반의 HS 품목분류 결정시스템과 결정방법에 관한 것으로, HS품목분류의 체계를 이루는 부(Section)와 류(Chapter)와 호(Heading)와 소호(Sub-Heading) 등급에 대한 체계정보와, 등급명과, 등급별로 링크된 추론규칙정보를 저장하는 분류체계DB; 상기 등급별 품목 확인을 위한 질의키워드와 예시품명에 관한 용어정보를 저장하되, 상기 예시품명은 유의어 및 동일어를 포함하는 용어정보DB; 상기 등급별 품목들의 용도와 기능 및 재질에 관한 특징정보를 저장하는 특징정보DB; 국내외 HS품목분류 사례 또는 미확인 품명 확정 사례에 관한 사례정보를 저장하는 사례정보DB; 사용자와의 질의 및 응답 절차를 진행하는 입출력모듈; 상기 DB들의 정보에 따른 질의를 통해 HS품목분류를 진행하는 추론모듈; HS품목분류의 경합 해소, 불분명한 품명 확인, HS품목분류 결과의 검증 진행을 위해서, 상기 DB들의 정보에 따라 질의를 수행하고 처리하는 학습정보모듈;을 포함하는 것이다.
=> HS품목분류 8 등장

mixed(복합어 및 분리된 단어 별도 저장)
hs품목분류": 5,
hs : 8,
품목분류 : 8,


discard (복합어 버리고 분리된 단어만 저장)
품목분류 : 8,
품목 : 2,
hs : 8,


none (복합어 처리 안함) => 검색 시 hs 품
hs품목분류 :5,
품목분류 : 3,
hs : 3,




#### doc 안에 중첩 필드 조회 쿼리 예시
문서 안에 NE 필드의 여러 항목 중 entity 는 프로세서 , type 은 TM, 문서의 ipc 는 G06F를 찾는 쿼리
!주의: 인덱스 설정 시 nested 타입으로 하지 않을 경우, NE 필드 내 여러 항목 중 프로세서도 있고 TM 있으면 조회가 되므로 nested타입 및 쿼리시에도 적용
```
GET corpus_patent/_search
{
  "query": {
    "bool": {
      "must": [
        {
          "nested": {
            "path": "NE",
            "query": {
              "bool": {
                "must": [
                  {
                    "term": {
                      "NE.entity": {
                        "value": "프로세서"
                      }
                    }
                  },
                  {
                    "term": {
                      "NE.type": {
                        "value": "TM"
                      }
                    }
                  }
                ]
              }
            }
          }
        },
        {
          "term": {
            "ipc": {
              "value": "G06F"
            }
          }
        }
      ]
    }
  }
}
```


### id wildcard search
```
POST corpus_patent_sentence/_search
{
  "_source": "NE.entity", 
  "query": {
    "script": {
      "script": "doc['_id'][0].indexOf('1020170139607') > -1"
    }
  }
}
```