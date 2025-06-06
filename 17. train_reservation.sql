DELIMITER //

CREATE PROCEDURE InsertTestData()
BEGIN
    -- 변수 선언
    DECLARE member1_seq, member2_seq BIGINT;
    DECLARE train1_seq, train2_seq BIGINT;
    DECLARE station1_seq, station2_seq, station3_seq BIGINT;
    DECLARE st_detail1_seq, st_detail2_seq, st_detail3_seq BIGINT;
    DECLARE schedules1_seq BIGINT;
    DECLARE sch_detail1_seq, sch_detail2_seq BIGINT;
    DECLARE seat1_seq, seat2_seq, seat3_seq BIGINT;
    DECLARE reservation1_seq BIGINT;

    -- 1. 회원 데이터 추가
    INSERT INTO member(id, password, name, tp_no, create_at, update_at) VALUES
    ('user01', 'pass123', '홍길동', '010-1111-1111', NOW(), NOW()),
    ('user02', 'pass456', '이순신', '010-2222-2222', NOW(), NOW());
    SET member1_seq = LAST_INSERT_ID() - 1;
    SET member2_seq = LAST_INSERT_ID();

    -- 2. 열차 데이터 추가
    INSERT INTO train(train_id, type, create_at, update_at) VALUES
    ('KTX-101', 'ktx', NOW(), NOW()),
    ('SRT-302', 'srt', NOW(), NOW());
    SET train1_seq = LAST_INSERT_ID() - 1;
    SET train2_seq = LAST_INSERT_ID();

    -- 3. 역 데이터 추가
    INSERT INTO station(station_id, create_at, update_at) VALUES
    ('서울역', NOW(), NOW()),
    ('대전역', NOW(), NOW()),
    ('부산역', NOW(), NOW());
    SET station1_seq = LAST_INSERT_ID() - 2;
    SET station2_seq = LAST_INSERT_ID() - 1;
    SET station3_seq = LAST_INSERT_ID();

    -- 4. 역 상세(승강장) 데이터 추가
    INSERT INTO station_detail(track, station_seq, create_at, update_at) VALUES
    (1, station1_seq, NOW(), NOW()), -- 서울역 1번 트랙
    (3, station2_seq, NOW(), NOW()), -- 대전역 3번 트랙
    (5, station3_seq, NOW(), NOW()); -- 부산역 5번 트랙
    SET st_detail1_seq = LAST_INSERT_ID() - 2;
    SET st_detail2_seq = LAST_INSERT_ID() - 1;
    SET st_detail3_seq = LAST_INSERT_ID();

    -- 5. 좌석 데이터 추가
    INSERT INTO seat(room_id, seat_id, create_at, update_at) VALUES
    ('1호차', '1A', NOW(), NOW()),
    ('1호차', '1B', NOW(), NOW()),
    ('2호차', '3C', NOW(), NOW());
    SET seat1_seq = LAST_INSERT_ID() - 2;
    SET seat2_seq = LAST_INSERT_ID() - 1;
    SET seat3_seq = LAST_INSERT_ID();
    
    -- 6. 운행 스케줄 추가 (서울 -> 부산)
    INSERT INTO schedules(route_depatment, route_destination, route_depatment_time, route_destination_time, train_seq, create_at, update_at) VALUES
    ('서울역', '부산역', '2025-07-01 09:00:00', '2025-07-01 11:30:00', train1_seq, NOW(), NOW());
    SET schedules1_seq = LAST_INSERT_ID();

    -- 7. 운행 스케줄 상세 추가 (서울->대전, 대전->부산)
    INSERT INTO schedules_detail(taken_times, department, destination, depatment_time, destination_time, station_detail_seq, schedules_seq, create_at, update_at) VALUES
    ('2025-07-01 09:00:00', '서울역', '대전역', '2025-07-01 09:00:00', '2025-07-01 10:00:00', st_detail1_seq, schedules1_seq, NOW(), NOW()),
    ('2025-07-01 10:05:00', '대전역', '부산역', '2025-07-01 10:05:00', '2025-07-01 11:30:00', st_detail2_seq, schedules1_seq, NOW(), NOW());
    SET sch_detail1_seq = LAST_INSERT_ID() - 1;
    SET sch_detail2_seq = LAST_INSERT_ID();
    
    -- 8. 예매 데이터 추가 (홍길동이 서울->부산 KTX 예매)
    INSERT INTO reservation(member_seq, reservation_id, status, create_at, update_at) VALUES
    (member1_seq, CONCAT('RES', DATE_FORMAT(NOW(), '%Y%m%d'), '-001'), '예매 완료', NOW(), NOW());
    SET reservation1_seq = LAST_INSERT_ID();

    -- 9. 결제 데이터 추가 (홍길동이 예매건 결제)
    INSERT INTO payment(amount, type, reservation_seq, member_seq, create_at, update_at) VALUES
    (59800, '국민', reservation1_seq, member1_seq, NOW(), NOW());
    
    -- 10. 좌석 관리 데이터 추가 (예매된 좌석과 비어있는 좌석)
    -- 홍길동이 예매한 좌석 (서울->대전 구간, 1호차 1A)
    INSERT INTO seat_management(reservation_seq, is_available, price, seat_seq, schedules_detail_seq, create_at, update_at) VALUES
    (reservation1_seq, 'false', 23700, seat1_seq, sch_detail1_seq, NOW(), NOW());
    -- 홍길동이 예매한 좌석 (대전->부산 구간, 1호차 1A)
    INSERT INTO seat_management(reservation_seq, is_available, price, seat_seq, schedules_detail_seq, create_at, update_at) VALUES
    (reservation1_seq, 'false', 36100, seat1_seq, sch_detail2_seq, NOW(), NOW());
    -- 아직 예매 가능한 다른 좌석 (서울->대전 구간, 1호차 1B)
    INSERT INTO seat_management(reservation_seq, is_available, price, seat_seq, schedules_detail_seq, create_at, update_at) VALUES
    (NULL, 'true', 23700, seat2_seq, sch_detail1_seq, NOW(), NOW());
    
END //

DELIMITER ;