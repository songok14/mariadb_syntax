-- pk, fk, unique 제약조건 추가 시 인덱스 페이지 자동생성
-- 조회 성능 향상 / 추가, 수정, 삭제 성능 하락

-- index 조회
show index from author;

-- index 삭제
alter table author drop index 인덱스명;

-- index 생성
create index 인덱스명 on 테이블(컬럼명);

-- index를 통해 조회 성능 향상을 얻으려면 반드시 where 조건에 해당컬럼에 대한 조건이 있어야 한다.
select * from author where email='hong@naver.com';

-- 만약 where 절에서 2개 이상의 컬럼이 있을 때 1개의 컬럼에만 index가 있다면 ->
select * from author where name like '%hong%' and email='hong@naver.com0';

-- 만약 where 조건에서 2컬럼으로 조회 시 2컬럼 각각에 index가 있다면 ->
-- 이 경우 db엔진에서 최적의 알고리즘 실행.
select * from author where name like '%hong%' and email='hong@naver.com0';

-- index는 1컬럼 뿐만아니라 2컬럼을 대상으로 1개의 index를 설정하는 것도 가능
-- 이 경우 두 컬럼을 and 조건으로 조회해야만 index를 사용
create index 인덱스명 on 테이블명(컬럼1, 컬럼2);

-- 기존 테이블 삭제 후 아래 테이블로 신규 생성
create table author(id bigint auto_increment, email varchar(255), name varchar(255), primary key(id));

-- index 테스트 시나리오
-- 아래 프로시저를 통해 수십만건의 데이터 insert 후에 index 생성 전후에 따라 조회 성능 확인
DELIMITER //
CREATE PROCEDURE insert_authors()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE email VARCHAR(100);
    DECLARE batch_size INT DEFAULT 10000; -- 한 번에 삽입할 행 수
    DECLARE max_iterations INT DEFAULT 100; -- 총 반복 횟수 (1000000 / batch_size)
    DECLARE iteration INT DEFAULT 1;
    WHILE iteration <= max_iterations DO
        START TRANSACTION;
        WHILE i <= iteration * batch_size DO
            SET email = CONCAT('song', i, '@naver.com');
            INSERT INTO author (email) VALUES (email);
            SET i = i + 1;
        END WHILE;
        COMMIT;
        SET iteration = iteration + 1;
        DO SLEEP(0.1); -- 각 트랜잭션 후 0.1초 지연
    END WHILE;
END //
DELIMITER ;