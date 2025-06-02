# 덤프파일 생성
mysqldump -u root -p 스키마명 > 덤프파일명
mysqldump -u root -p board > mydumpfile.sql

# 도커 사용 시(생성)
docker exec -it 6570308ed5c6 mariadb-dump -u root -p board > mydumpfile.sql
docker exec -it 컨테이너ID ~~~~~~ # 컨테이너에 오른쪽에 정의한 키워드 전달

# 덤프파일 적용(복원)
mysqldump -u root -p 스키마명 < 덤프파일명
mysqldump -u root -p board < mydumpfile.sql

# 도커 사용 시(복원원)
docker exec -i 컨테이너ID
docker exec -i 6570308ed5c6 mariadb -u root -p1234 board < mydumpfile.sql