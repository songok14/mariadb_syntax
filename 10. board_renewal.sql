-- 사용자 테이블 생성
create table author
(id bigint auto_increment, email varchar(50) not null,
name varchar(100), password varchar(255) not null, primary key(id));


-- 주소 테이블 생성
create table address
(id bigint auto_increment, country varchar(255) not null,
 city varchar(255) not null, street varchar(255) not null,
 author_id bigint not null, primary key(id), foreign key(author_id) references author(id));

-- post 테이블 생성
create table post
(id bigint auto_increment, title varchar(255) not null, 
contents varchar(1000), primary key(id));


-- 연결 테이블 생성
create table author_post
(id bigint auto_increment, author_id bigint not null, post_id bigint not null, 
primary key(id),
foreign key(author_id) references author(id), 
foreign key(post_id) references post(id));

-- 복합키를 이용한 연결 테이블 생성
create table author_post2
(auto_increment, author_id bigint not null, post_id bigint not null, 
primary key(author_id, post_id),
foreign key(author_id) references author(id), 
foreign key(post_id) references post(id));

-- 회원가입 및 주소생성
DELIMITER //
create procedure insert_author(in emailInput varchar(255), in nameInput varchar(255), in passwordInput varchar(255),in countryInput varchar(255), in cityInput varchar(255), in streetInput varchar(255))
begin
    declare exit handler for SQLEXCEPTION
    begin
        rollback;
    end;
    start transaction;
    insert into author(email, name, password) values (emailInput, nameInput, passwordInput);
    insert into address(author_id, country, city, street) values((select id from author order by id desc limit 1) , countryInput, cityInput, streetInput);
    commit;
end //
DELIMITER ;

-- 글쓰기
DELIMITER //
create procedure insert_post(in titleInput varchar(255), in contentsInput varchar(255), in emailInput varchar(255))
begin
    declare exit handler for SQLEXCEPTION
    begin
        rollback;
    end;
    start transaction;
    insert into post(title, contents) values (titleInput, contentsInput);
    insert author_post(author_id, post_id) values((select id from author where email=emailInput), (select id from post order by id desc limit 1));
    commit;
end //
DELIMITER ;


-- 글편집하기
DELIMITER //
create procedure edit_post(in titleInput varchar(255), in contentsInput varchar(255), in emailInput varchar(255), in idInput bigint)
begin
    declare exit handler for SQLEXCEPTION
    begin
        rollback;
    end;
    start transaction;
    update post set title=titleInput, contents=contentsInput where id=idInput;
    insert author_post(author_id, post_id) values((select id from author where email=emailInput), idInput);
    commit;
end //
DELIMITER ;

-- JOIN하여 데이터 조회
select p.title as '제목', p.contents as '내용', a.name as '이름' from post p inner join author_post ap on p.id=ap.post_id
inner join author a on a.id=ap.author_id;