-- insert, into, values : 테이블에 데이터 삽입
insert into 테이블명(컬럼1, 컬럼2, ...) values(데이터1, 데이터2, ...)
insert into author(id, name, email) values(3, 'hong3', 'hong3@naver.com');  -- 문자열은 일바적으로 작음 따옴표 사용

-- update, set : 테이블에 데이터 변경
update author set name='홍길동', email='hong100@naver.com' where id=3;

-- select, from : 조회
select 컬럼1, 컬럼2, ... from 테이블명;
select name, email from author;
select * from author;

-- delete : 삭제
delete from 테이블명 where 조건;
delete from author where id=3;

-- 실습 :
-- 테스트 데이터
insert into author(id, name, email) values(5, '홍길동5', '홍길동5@naver.com');
select * from author;                       -- 조건 없이 모든 데이터 조회
select * from author where id=1;            -- id가 1인 데이터만 조회
select * from author where name='홍길동';    -- name이 홍길동인 데이터만 조회
select * from author where id>3;            -- id가 3보다 큰 데이터 조회
select * from author where id>2 and name='홍길동4';            -- id가 3보다 큰 데이터 조회

-- 중복제거 조회 : distinct
select distinct name from author;

-- 정렬 : order by 컬럼명
-- asc : 오름차순 / desc : 내림차순 / 안붙이면 오름차순(default)
-- 아무런 정렬조건 없이 조회할 경우 pk 기준으로 오름차순
select * from author order by name;         -- 오름차순
select * from author order by name desc;    -- 내림차순

-- 멀티컬럼 order by : 여러 컬럼으로 정령 시, 먼저 쓴 컬럼 우선정렬, 중복 시 다음 옵션으로 정렬
select * from author order by name desc, email asc; -- name 으로 정렬 후, 중복되면 asc로 정렬렬

-- 결과값 개수 제한 : limit
select * from author order by id desc limit 1;  -- 가장 최신의 데이터

-- 별칭(alias)를 이용한 select
select name as '이름', email as '이메일' from author;
select a.name, a.email from author as a;
select a.name, a.email from author a;

-- null을 조회조건으로 활용
select * from author where password is null;
select * from author where password is not null;

-- 프로그래머스
-- 여러 기준으로 정렬하기