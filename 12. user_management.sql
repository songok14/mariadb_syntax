-- 사용자 관리
-- 사용자 목록 조회
select * from mysql.user;

-- 사용자 생성
create user 'crong94'@'%' identified by '4321';

-- 권한부여
grant select on board.author to 'crong94'@'%';
grant select, insert on board.* to 'crong94'@'%';
grant all privileges on board.* to 'crong94'@'%';

-- 권한 회수
revoke select on board.author from 'crong94'@'%';

-- 사용자 권한 조회
show grants for 'crong94'@'%';

-- 사용자 계정 삭제
drop user 'crong94'@'%';