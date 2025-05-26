-- tinyint : -127 ~ 128까지 표현
-- age 컬럼 int -> tinyint
alter table author modify column age tinyint unsigned;

-- author, post 테이블 id값 bigint로 변경
alter table author modify column id bigint primary key;
alter table post modify column id bigint;

-- decimal(총 자리수, 소수부 자리수)
alter table post add column price deciaml(10,3);
-- 소수점 자리수 초과 시 짤림현상 발생
insert into post(id, title, price, author_id) values(7, 'hansot', 10.1234);

-- 문자타입 : 고정길이(char), 가변길이(varchar)
alter table author add column gender char(10);
alter table author add column selt_introduction text;

-- blob(바이너리데이터) 타입 실습
-- 일반적으로 blob으로 저장하기 보다, varchar로 설계하고 이미지 경로만을 저장함.
alter table author add column profile_image longblob;
insert into author(id, email, profile_image) values(8, 'aaa@naver.com', LOAD_FILE('C:\\test.jpg'));

-- enum : 삽입될 수 있는 데이터의 종류를 한정하는 데이터 타입
alter table author add column role enum('admin', 'user') not null default 'user';
-- enum에 지정된 값이 아닌경우
insert into author(id, email, role) values(9, 'bbb@naver.com', 'admin2');
-- role을 지정안한 경우
insert into author(id, email) values(9, 'bbb@naver.com');
-- enum에 지정된 값인 경우
insert into author(id, email, role) values(10, 'ccc@naver.com', 'admin');

-- date와 datatime
alter table author add column birthday date;
alter table post add column created_time datetime;
insert into post(id, title, author_id, created_time) values(7, 'hello', 3, '2025-05-23 14:36:30');

alter table post modify column created_time datetime default current_timestamp();

-- 비교 연산자
select * from author where id>=2 and id<=4;
select * from author where id between 2 and 4;
select * from author where id in(2,3,4);

-- like : 특정 문자를 포함하는 문자열 조회
select * from post where title like 'world%';
select * from post where title like '%world';
select * from post where title like '%world%';

select * from post where author_id in(select id from author where name='hong1');

-- regexp : 정규표현식을 활요한 조회
select * from post where title regexp '[a-z]'; --하나라도 알파벳 소문자가 들어있으면
select * from post where title regexp '[가-힣]'; -- 하나라도 한글이 있으면

-- 숫자 -> 날짜
select cast(20250523 as date); -> 2025-05-23
select cast(num as date) from author;   --num은 author 테이블의 컬럼

-- 문자 -> 날짜
select cast('20250523' as date);

-- 문자 -> 숫자
select cast('12' as int);       -- 일부 시스템에서 안먹음
select cast('12' as unsigned);  -- 공식에서 권장 사항
  * int 대신 unsigned로 사용하는 것이 좋음

-- 날짜 조회 방법 : 2025-05-23 14:30:25
-- like 패턴, 부등호, date_format : 사용가능
select * from post where created_time like '2025-05%';
-- 5월 1일부터 5월 20일까지
-- 2025-05-01 만 입력 시 시간은 00:00:00으로 자동 입력
select * from post where created_time >= '2025-05-01' and created_time <'2025-05-21';
select * from post where date_format(created_time, '%Y-%m-%d') >= '2025-05-01' and date_format(created_time, '%Y-%m-%d') <='2025-05-20';

select date_format(created_time, '%Y-%m-%d') from post;
select date_format(created_time, '%H:%i:%s') from post;
select * from post where date_format(created_time, '%m') = '05';

-- 날짜타입 -> 숫자로 변환 후 조회회
select * from post where cast(date_format(created_time, '%m') as unsigned) = 5;