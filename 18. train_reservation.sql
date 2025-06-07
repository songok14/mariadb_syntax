delimiter //

-- 프로시저 생성
create procedure insesrt_test_data()
begin
    declare i int default 1;
    declare v_departure_station varchar(255);
    declare v_destination_station varchar(255);
    declare v_via_station varchar(255);
    declare v_departure_datetime datetime;
    declare v_destination_datetime datetime;
    declare v_via_arrival_datetime datetime;
    declare v_via_departure_datetime datetime;

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
    
    -- 6 & 7. 운행 스케줄 및 스케줄 상세 50개 추가
    set i = 1;
    while i <= 50 do
        -- 서로 다른 출발역, 경유역, 도착역 설정
        set v_departure_station = concat('테스트', floor(1 + rand() * 30), '역');
        repeat
            set v_via_station = concat('테스트', floor(1 + rand() * 30), '역');
        until v_via_station != v_departure_station end repeat;
        repeat
            set v_destination_station = concat('테스트', floor(1 + rand() * 30), '역');
        until v_destination_station != v_departure_station and v_destination_station != v_via_station end repeat;

        -- 2025년 6월 10일 내 랜덤 출발 시간 및 도착 시간 설정
        set v_departure_datetime = timestamp('2025-06-10', sec_to_time(floor(rand() * 86400)));
        set v_destination_datetime = date_add(v_departure_datetime, interval (120 + floor(rand() * 240)) minute);

        -- 스케줄 추가 (전체 여정)
        insert into schedules(route_departure, route_destination, route_departure_time, route_destination_time, train_seq) values
        (v_departure_station, v_destination_station, v_departure_datetime, v_destination_datetime, floor(1 + rand() * 19));

        -- 경유지 시간 계산
        set v_via_arrival_datetime = timestampadd(second, timestampdiff(second, v_departure_datetime, v_destination_datetime) * (0.4 + rand() * 0.2), v_departure_datetime);
        set v_via_departure_datetime = date_add(v_via_arrival_datetime, interval (5 + floor(rand() * 11)) minute);

        -- 스케줄 상세 추가 (구간 1: 출발지 -> 경유지)
        insert into schedules_detail(taken_times, departure, destination, departure_time, destination_time, station_detail_seq, schedules_seq) values
        (v_departure_datetime, v_departure_station, v_via_station, v_departure_datetime, v_via_arrival_datetime, floor(1 + rand() * 59), i);
        
        -- 스케줄 상세 추가 (구간 2: 경유지 -> 도착지)
        insert into schedules_detail(taken_times, departure, destination, departure_time, destination_time, station_detail_seq, schedules_seq) values
        (v_via_departure_datetime, v_via_station, v_destination_station, v_via_departure_datetime, v_destination_datetime, floor(1 + rand() * 59), i);

        set i = i + 1;
    end while;
    
    -- 8. 예매 30건 추가
    set i = 1;
    while i <= 30 do
        insert into reservation(member_seq, reservation_id, status) values
        (i, concat('res', date_format(now(), '%y%m%d'), '-', lpad(i, 5, '0')), '예매 완료');
        set i = i + 1;
    end while;

    -- 9. 결제 30건 추가
    set i = 1;
    while i <= 30 do
        insert into payment(amount, type, reservation_seq, member_seq) values
        (floor(30000 + rand() * 30000), '국민', i, i);
        set i = i + 1;
    end while;
    
    -- 10. 좌석 관리 데이터 추가
    set i = 1;
    while i <= 30 do
        insert into seat_management(reservation_seq, is_available, price, seat_seq, schedules_detail_seq) values
        (i, 'false', floor(15000 + rand() * 15000), i, i);
        set i = i + 1;
    end while;

    set i = 31;
    while i <= 200 do
        insert into seat_management(reservation_seq, is_available, price, seat_seq, schedules_detail_seq) values
        (null, 'true', floor(15000 + rand() * 15000), i, floor(1 + rand() * 99));
        set i = i + 1;
    end while;

end //
delimiter ;