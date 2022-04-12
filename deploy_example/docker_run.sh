docker run -v ./${INSTALLED_APP}/edap/:/app/ -v ./soynlp_branch:/soynlp_branch -p 8600:8000 --name ${INSTALLED_APP}-prod localhost/edap:latest  /bin/bash -c 'cd /soynlp_branch && python setup.py install && cd /app && /django_start_prod.sh'

docker run -p 8000:8000 --name limnet_backend_container localhost/limenet_back:lastest

podman run -p 80:80 --name limnet_front_container 

docker run -p 8600:8000 -v ./${INSTALLED_APP}/edap/:/app/ --name ${INSTALLED_APP}-prod localhost/edap:latest  /bin/bash -c 'cd /app && ./django_start_prod.sh'

podman run -d -p 8600:8000 -v /data/{INSTALLED_FOLDER}/${INSTALLED_APP}/edap/:/app/ -v /data/static:/.static_root -v /data/media:/app/media --name analysis-engine-01 localhost/edap:latest  /bin/bash -c 'cd /app && /django_start_prod.sh'
podman run -d -p 8601:8000 -v /data/{INSTALLED_FOLDER}/${INSTALLED_APP}/edap/:/app/ -v /data/static:/.static_root -v /data/media:/app/media --name analysis-engine-02 localhost/edap:latest  /bin/bash -c 'cd /app && /django_start_prod.sh'