[공식설치문서](https://www.visual-paradigm.com/support/documents/teamcollaborationguide/1337/1340/40483_installingte.html)

### 설치 중 trouble shooting
**데이터베이스 연결 중 Timezone 에러 발생 시 **
jdbc 로 timezone 명시해서 연결
jdbc:mysql://${db_ip}:${db_port}/vp?characterEncoding=UTF-8&serverTimezone=Asia/Seoul

**admin server site에서 프로젝트 생성이 안될 시**
root 계정이 아닌 일반 계정으로 설치 시 권한 문제로 프로젝트 생성이 안될 수 있음.
압축을 sudo 권한으로 풀고, start.sh 파일도 sudo 권한으로 실행.