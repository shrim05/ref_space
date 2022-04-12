podman run -d -p 8600:8000 \
-v /data/logs/anal_engine02:/app/logs \
-v /data/static:/.static_root \
-v /data/media:/app/media \
--name analysis-engine-01 \
localhost/edap:latest \
/bin/bash -c 'cd /app && /django_start_prod.sh'
podman run -d -p 8601:8000 \ 
-v /data/logs/anal_engine02:/app/logs \
-v /data/static:/.static_root \
-v /data/media:/app/media \
--name analysis-engine-02 \
localhost/edap:latest  \
/bin/bash -c 'cd /app && /django_start_prod.sh'
