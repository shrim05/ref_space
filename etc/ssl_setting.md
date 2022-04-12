# OpenSSL 

# 인증 연장
```shell
#test
sudo certbot renew --dry-test
#갱신
sudo certbot renew

#nginx 에서 바인딩 된 폴더로 복사
sudo cp -r /etc/letsencrypt/ /data/cert_for_nginx/

#바인딩 폴더 소유권 변경
sudo chown -cR analysis-4:analysis-4 /data/cert_for_nginx

#nginx 재시작
docker-compose restart
```