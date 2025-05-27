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
