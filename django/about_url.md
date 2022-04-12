# 간단한 URL 설정
## path, include
### path(route, view, kwargs=None, name=None)
```python
from django.urls import include, path

urlpatterns = [
    path('index/', views.index, name='main-view'),
    path('bio/<username>/', views.bio, name='bio'),
    path('articles/<slug:title>/', views.article, name='article-detail'),
    path('articles/<slug:title>/<int:section>/', views.section, name='article-section'),
    path('weblog/', include('blog.urls')),
    ...
```
- route: 
    - string 또는 gettext_lazy()
    - angle brackets \<username\>  로 감싸면 URL에서 해당 부분을 캡쳐해서 지정한 keyword argument로 view에 전달
    - type 지정 가능 \<int:section> string->해당 타입으로 변경됨

### re_path(route, view, kwargs=None, name=None)
```python
from django.urls import include, re_path

urlpatterns = [
    re_path(r'^index/$', views.index, name='index'),
    re_path(r'^bio/(?P<username>\w+)/$', views.bio, name='bio'),
    re_path(r'^weblog/', include('blog.urls')),
    ...
]
```
- route
    - python re module 사용. 정규식표현으로 url 패턴 지정
    - 캡쳐 이름 지정 시 해당 이름으로 view에 전달, 이름 지정 안되면 positional 인자로 전달
    - string으로 전달(타입 변환 안됨)

### include()
include(module, namespace=None)¶
include(pattern_list)
include((pattern_list, app_namespace), namespace=None)
