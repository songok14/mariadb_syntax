-- mariadb 서버에 접속
mariadb -u root -p -- 입력 후 비밀번호 별도 입력(보안)

-- 명령문은 대문자 / 테이블명, 컬럼명 등은 소문자로 명시하는게 관례

-- 스키마(database) 생성
create database 스키마명명;

-- 스키마 목록 조회
show databases;

-- 스키마 선택
use 스키마명;

-- 스키마 삭제
drop database 스키마명;

-- 테이블 목록 조회
show tables

-- 문자인코딩 변경
alter database board default character set = utf8mb4;

-- 문자인코딩 조회
show variables like 'character_set_server';

-- 테이블 생성
create table 테이블명(컬렴1 타입 primary key, 컬럼2 타입, 컬럼3 타입);
create table author(id int primary key, name varchar(255), email varchar(255), password varchar(255));

-- 테이블 컬럼정보 조회
describe 테이블명;

-- 테이블 생성 명령문 조회
show create table 테이블명;

-- posts 테이블 신규 생성(id(pk), title, contents, author_id(fk, not null))
create table posts(id int, title varchar(255), contents varchar(255), author_id int not null, primary key(id), foreign key(author_id) references author(id));

-- 테이블 제약조건 조회
select * from information_schema.key_column_usage where table_name='posts';

-- 테이블 index 조회
show index from 테이블명;

-- alter : 테이블 구조를 변경
alter table 테이블명 rename 바꿀테이블명;

-- 테이블에 컬럼 추가
alter table 테이블명 add column 컬럼명 타입 (제약조건);

-- 테이블 컬럼 삭제
alter table 테이블명 drop column 컬럼명;

-- 테이블 컬럼명 변경
alter table 테이블명 change column 컬럼명 바꿀컬럼명 타입;

-- 테이블 컬럼의 타입과 제약조건 변경
alter table author modify column email varchar(100) not null;
alter table author modify column email varchar(100) not null unique;

-- 실습 : author 테이블에 address 컬럼 추가(varchar 255)
alter table autor add column address varchar(255);

-- 실습 : post 테이블에 title은 not null로 변경, content는 길이 3000자로 변경
alter table post modify column title varchar(255) not null, modify column content varchar(3000);

-- drop : 테이블 삭제
drop table abc;

-- 일련의 쿼리를 실행시킬때 특정 쿼리에서 에러가 나지 않도록 if exists를 많이 활용
drop table if exists abc;
select * from author;
