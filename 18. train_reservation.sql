-- 대량 데이터 추가

delimiter //

create procedure insertbulkdata_partialreservations()
begin
    declare i int default 1;

    -- 0. 기존 데이터 삭제 및 auto_increment 초기화
    set foreign_key_checks = 0;
    truncate table member;
    truncate table train;
    truncate table station;
    truncate table station_detail;
    truncate table seat;
    truncate table schedules;
    truncate table schedules_detail;
    truncate table reservation;
    truncate table payment;
    truncate table seat_management;
    set foreign_key_checks = 1;

    -- 1. 회원 100명 추가
    set i = 1;
    while i <= 100 do
        insert into member(id, password, name, tp_no, point_score) values
        (concat('user', lpad(i, 3, '0')), 'password123', concat('회원', i), concat('010-', lpad(floor(rand() * 10000), 4, '0'), '-', lpad(i, 4, '0')), floor(rand() * 5000));
        set i = i + 1;
    end while;
    
    -- 2. 열차 20대 추가
    set i = 1;
    while i <= 20 do
        insert into train(train_id, type) values
        (concat(if(rand() > 0.5, 'ktx', 'srt'), '-', lpad(100 + i, 4, '0')), if(rand() > 0.5, 'ktx', 'srt'));
        set i = i + 1;
    end while;

    -- 3. 역 30개 추가
    set i = 1;
    while i <= 30 do
        insert into station(station_id) values (concat('테스트', i, '역'));
        set i = i + 1;
    end while;

    -- 4. 역 상세(승강장) 60개 추가 (역 당 2개씩)
    set i = 1;
    while i <= 30 do
        insert into station_detail(track, station_seq) values (floor(1 + rand() * 5), i);
        insert into station_detail(track, station_seq) values (floor(6 + rand() * 5), i);
        set i = i + 1;
    end while;
    
    -- 5. 좌석 200개 추가
    set i = 1;
    while i <= 200 do
        insert into seat(room_id, seat_id) values
        (concat(floor((i-1)/20) + 1, '호차'), concat(mod(i-1, 20) + 1, char(65 + floor(rand()*4))));
        set i = i + 1;
    end while;
    
    -- 6. 운행 스케줄 50개 추가
    set i = 1;
    while i <= 50 do
        -- ddl에 맞춰 route_departure, route_departure_time 사용
        insert into schedules(route_departure, route_destination, route_departure_time, route_destination_time, train_seq) values
        (concat('테스트', floor(1 + rand() * 29), '역'), concat('테스트', floor(1 + rand() * 29), '역'), '2025-08-01 10:00:00', '2025-08-01 12:00:00', floor(1 + rand() * 19));
        set i = i + 1;
    end while;

    -- 7. 스케줄 상세 100개 추가 (스케줄 당 2개 구간)
    set i = 1;
    while i <= 50 do
        -- ddl에 맞춰 departure_time 사용
        insert into schedules_detail(taken_times, departure, destination, departure_time, destination_time, station_detail_seq, schedules_seq) values
        ('2025-08-01 10:00:00', '출발지', '경유지', '2025-08-01 10:00:00', '2025-08-01 11:00:00', floor(1 + rand() * 59), i),
        ('2025-08-01 11:05:00', '경유지', '도착지', '2025-08-01 11:05:00', '2025-08-01 12:00:00', floor(1 + rand() * 59), i);
        set i = i + 1;
    end while;
    
    -- 8. 예매 30건 추가 (회원 1~30번만 예매 진행)
    set i = 1;
    while i <= 30 do
        insert into reservation(member_seq, reservation_id, status) values
        (i, concat('res', date_format(now(), '%y%m%d'), '-', lpad(i, 5, '0')), '예매 완료');
        set i = i + 1;
    end while;

    -- 9. 결제 30건 추가 (예매 30건에 대해서만)
    set i = 1;
    while i <= 30 do
        insert into payment(amount, type, reservation_seq, member_seq) values
        (floor(30000 + rand() * 30000), '국민', i, i);
        set i = i + 1;
    end while;
    
    -- 10. 좌석 관리 데이터 추가 (예매된 좌석 30개 + 예매 가능한 좌석 170개)
    -- 예매된 좌석 30개
    set i = 1;
    while i <= 30 do
        insert into seat_management(reservation_seq, is_available, price, seat_seq, schedules_detail_seq) values
        (i, 'false', floor(15000 + rand() * 15000), i, i); -- 예매seq, 좌석seq, 스케줄상세seq를 1:1로 단순화
        set i = i + 1;
    end while;

    -- 예매 가능한 좌석 170개
    set i = 31;
    while i <= 200 do
        insert into seat_management(reservation_seq, is_available, price, seat_seq, schedules_detail_seq) values
        (null, 'true', floor(15000 + rand() * 15000), i, floor(1 + rand() * 99)); -- 특정 스케줄에 대해 예매 가능함
        set i = i + 1;
    end while;

end //

delimiter ;