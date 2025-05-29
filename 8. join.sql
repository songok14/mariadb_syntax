-- post 테이블의 author_id 값을 unllable하게 변경
alter table post modify column author_id bigint

-- post 테이믈에 글쓴적이 있는 author와 글쓴이가 author에 있는 post 데이터를 결합하여 출력
select * from author inner join post on author.id=post.author_id;
select * from author as A inner join post as B on A.id=B..author_id;

-- 출력순서만 달라질뿐 위 커리와 동일하게 작동
select a.*, p.* from author as A inner join post as B on A.id=B..author_id;

-- 글쓴이가 있는 글 전체 정보와 글쓴이의 이메일만 출력
-- post의 글쓴이가 없는 데이터는 제외, 글쓴이중에 글쓴적 없는 사람도 제외
select p.*, a.email from post p inner join author a on author_id=p.author_id;

-- 글쓴이가 있는 글의 제목, 내용, 글쓴이의 이름만 출력하시오
select p.title, p.content, a.name from post p inner join author a on a.id=p.author_id;

-- A left Join B : A 테이블의 데이터는 모두 조회하고 관련있는 (on조건) B 데이터도 출력
-- 글쓴이는 모두 출려하되, 글을 쓴적 있다면 관련 글도 같이 출력
select * from author a left join post p on a.id=p.author_id;

-- 모든 글 목록을 출력하고, 만약 저자가 있다면 이메일 정보 출력
select p.*, a.email from post p left join author a on a.id=p.author_id;

-- 모든 글 목록을 출력하고 관련된 저자 정보 출력(author_id가 not null 이라면)
select * from post p inner join author a on p.author = a.id;
select * from post p left join author a on p.author_id = a.id;

-- 실습) 글쓴이가 있는 글 중에서 글의 title 과 저자의 email을 출력하되, 저자의 나이가 30세 이상인 글만 출력
select p.title, a.email from post p left join author a on p.author_id = a.id where a.age>=30;
select p.title, a.email from post p inner join author a on p.author_id = a.id where a.age>= 30;

-- 전체 글 목록을 조회하되, 글의 저자의 이름이 비어져 있지 않은 글 목록만을 출력
select p.* from post p inner join author a on p.author_id=a.id where a.name is not null;

-- 조건에 맞는 도서와 저자 리스트 출력
SELECT B.BOOK_ID, A.AUTHOR_NAME, DATE_FORMAT(B.PUBLISHED_DATE, '%Y-%m-%d') AS PUBLISHED_DATE
FROM BOOK B LEFT JOIN AUTHOR A
ON B.AUTHOR_ID=A.AUTHOR_ID
WHERE B.CATEGORY='경제'
ORDER BY B.PUBLISHED_DATE, ASC;

-- 없어진 기록 찾기
SELECT O.ANIMAL_ID, O.NAME FROM ANIMAL_OUTS O
LEFT JOIN ANIMAL_INS I
ON O.ANIMAL_ID=I.ANIMAL_ID
WHERE I.ANIMAL_ID IS NULL;

SELECT O.ANIMAL_ID, O.NAME
FROM ANIMAL_OUTS O
WHERE O.ANIMAL_ID NOT IN (SELECT I.ANIMAL_ID FROM ANIMAL_INS I);

-- UNION : 두 테이블의 select 결과를 횡으로 결합(기본적으로 중복제거(distinct) 적용)
-- union 시킬 때 컬럼의 개수와 컬럼의 타입이 같아야함
select name, email from author union select title, content from post;

-- union all : 중복까지 모두 포함
select name, email from author union all select title, content from post;

-- 서브쿼리 : select 문 안에 또다른 select 문을 서브쿼리라 한다.

-- where 절 안에 서브쿼리
-- 한 번이라도 글을 쓴 author 목록 조회
select distinct a.* from author a inner join post p on a.id=p.author_id;
-- null 값은 in 조건절에서 자동으로 제외
select * from author where id in (select author_id from post);

-- 컬럼 위치에 서브쿼리
-- author의 email과 author 별로 본인의 쓴 글의 개수를 출력
select email, (select count(*) from post p where a.id=p.author_id) as count from author a;

-- from절 위치에 서브쿼리
select * from (select * from author where id > 5) as a;

-- group by 컬럼명 : 특정 컬럼으로 데이터를 그룹화하여 하나의 행(row)처럼 취급
select author_id from post group by author_id;

-- 보통 집계함수와 같이 많이 사용
select author_id, count(*) from post group by author_id;

-- 집계함수
-- null은 count에서 제외된다.
select count(*) from author;
select sum(price) from post;
select avg(price) from post;
-- 소수점 3번째 자리에서 반올림
select round(avg(price), 3) from post;

-- group by 와 집계함수
select author_id, count(*), sum(price) from post group by author_id;

-- where 와 group by
-- 날짜별 post 글의 개수 출력(날짜값이 null 제외)
select date_format(created_time, '%Y-%m-%d') as date, count(*) from post where created_time is not null group by date;

-- 자동차 종류 별 틀정 옵션이 포함된 자동차 수 구하기

-- group by 와 having
-- having은 group by를 통해 나온 집계값에 대한 조건
-- 글을 2번 이상 쓴 사람에 대한 ID 찾기
select author_id from post group by author_id having count(*) >= 2;

-- group by 첫번째컬럼, 두번째컬럼
-- 첫번째 컬럼으로 먼저 grouping 한 후 두번째 컬럼으로 grouping 한다.
-- post 테이블에서 작성자별로 만든 제목의 개수를 출력하시오
select author_id, title, count(*) from post group by author_id, title, from post group by author_id, title;