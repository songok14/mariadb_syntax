-- 특정 역의 전광판 출력
select sd.departure_time as '출발시간', sd.destination as '목적지', t.type as '열차종류', 
    t.train_id as '열차번호', std.track as '승강장' from schedules_detail sd
left join schedules s on sd.schedules_seq = s.seq
left join train t on s.train_seq = t.seq
left join station_detail std on sd.station_detail_seq = std.seq
-- 여기에서 원하는 출발역의 이름을 지정합니다.
where sd.departure = '테스트1역' order by sd.departure_time;

-- ================================================================================================
-- 같은 schedule_seq 내 출발/도착 한 줄에 출력
select s1.departure as '출발지', s1.departure_time as '출발시간',
    s2.destination as '도착지', s2.destination_time as '도착시간'
from schedules_detail as s1
inner join schedules_detail s2 on s1.schedules_seq = s2.schedules_seq
where s1.schedules_seq = 1 and s1.departure = '서울' and s2.destination = '부산';

-- ================================================================================================
-- 운행 상세 정보 출력(schedules_detail.seq를 조회 -> sd.seq를 기반으로 남은좌석 선택 -> 예약 프로시저로 예약)
-- 사용자 입력 값 (출발지, 도착지, 날짜)
set @departure_station = '테스트10역';
set @destination_station = '테스트29역';
set @departure_date = '2025-06-10';

select
    sd.seq as '스케줄상세번호', 
    sd.departure as '출발역',
    sd.departure_time as '출발시간',
    sd.destination as '도착역',
    sd.destination_time as '도착시간',
    t.type as '열차종류',
    t.train_id as '열차번호',
    -- 각 스케줄별 예매 가능한 좌석 수를 계산
    ifnull(available_seats.cnt, 0) as '예매가능좌석'
from
    schedules_detail sd
-- 열차 정보를 가져오기 위한 조인
left join schedules s on sd.schedules_seq = s.seq
left join train as t on s.train_seq = t.seq
-- 예매 가능한 좌석 수를 세기 위한 조인 (서브쿼리 사용)
left join (
    select schedules_detail_seq, count(*) as cnt
    from seat_management
    where is_available = 'true'
    group by schedules_detail_seq
) as available_seats on sd.seq = available_seats.schedules_detail_seq
where sd.departure = @departure_station
    and sd.destination = @destination_station
    and date(sd.departure_time) = @departure_date
order by sd.departure_time;

-- ================================================================================================
-- 남은 좌석 확인
-- 조회할 운행 스케줄의 id를 지정
set @schedule_detail_seq_to_view = 22;

select s.room_id as '객실', s.seat_id as '좌석번호', sm.price as '가격'
-- 좌석의 예매 상태와 가격 정보가 있는 seat_management를 기준으로
from seat_management sm
-- 좌석의 실제 이름(객실, 좌석번호)을 가져오기 위해 seat 테이블과 조인
join seat s on sm.seat_seq = s.seq
-- 사용자가 선택한 바로 그 운행 스케줄에 해당하는 정보만 필터링
-- 그리고 '예매 가능한' 상태의 좌석만 필터링
where sm.schedules_detail_seq = @schedule_detail_seq_to_view and sm.is_available = 'true'
-- 보기 좋게 객실, 좌석번호 순으로 정렬
order by s.room_id, s.seat_id;

-- ================================================================================================
-- 좌석 예약 프로시저
delimiter //
-- v_xxx: variabel(변수), i_xxx: insert(입력값)
create procedure seat_reservation(
    in i_member_id varchar(255),            -- 입력값 1: 회원 id
    in i_schedule_detail_seq bigint,        -- 입력값 2: 운행 상세 id
    in i_room_id varchar(10),               -- 입력값 3: 객실 번호
    in i_seat_id varchar(10)                -- 입력값 4: 좌석 번호
)
begin
    declare v_member_seq bigint;            
    declare v_seat_seq bigint;
    declare v_reservation_seq bigint;

    -- 입력 값을 기반으로 각 테이블의 pk (seq)를 조회
    select seq into v_member_seq from member where member_id = i_member_id;
    select seq into v_seat_seq from seat where room_id = i_room_id and seat_id = i_seat_id;

    start transaction;
    -- 예매 정보 생성
    insert into reservation (member_seq, reservation_id, status)
    values (v_member_seq, concat('res-', date_format(now(), '%Y%m%d'), lpad(v_member_seq, 5, '0')), '예매 완료');
    
    -- 방금 만들어진 reservation_id 저장
    set v_reservation_seq = last_insert_id();

    -- 좌석 상태 변경
    update seat_management
    set reservation_seq = v_reservation_seq, is_available = 'false'
    where seat_seq = v_seat_seq and is_available = 'true'
        and schedules_detail_seq = i_schedule_detail_seq;

    -- row_count(): 바로 직전에 실행된 insert, update, delete 구문에 의해 영향을 받은 행(row)의 개수를 반환하는 함수
    -- 업데이트 실패 시 롤백
    if row_count() = 0 then
        select '예약 실패: 해당 좌석은 이미 예매되었거나 존재하지 않습니다.' as '결과';
        rollback;
    
    -- 업데이트 성공 시 커밋
    else
        select '예약 성공!' as '결과', v_reservation_seq as '새 예약번호';
        commit;
    end if;

end //
delimiter ;

-- ================================================================================================
-- 여러 좌석 한 번에 예약
delimiter //

create procedure reserve_multi_segment_seat(
    in i_member_id varchar(255),          -- 입력값 1: 회원 id
    in i_schedules_seq bigint,            -- 입력값 2: 운행 정보 id (예: ktx 101편)
    in i_start_station varchar(255),      -- 입력값 3: 출발역 (예: '대전')
    in i_end_station varchar(255),        -- 입력값 4: 도착역 (예: '부산')
    in i_room_id varchar(10),             -- 입력값 5: 객실 번호
    in i_seat_id varchar(10)              -- 입력값 6: 좌석 번호
)
begin
    -- 변수 선언
    declare v_member_seq bigint;
    declare v_seat_seq bigint;
    declare v_reservation_seq bigint;
    declare v_schedules_detail_seq bigint;
    declare v_journey_start_time datetime; -- 전체 여정의 시작 시간
    declare v_journey_end_time datetime;   -- 전체 여정의 종료 시간
    declare v_error_flag int default 0;
    declare v_done int default false;

    -- 커서 선언: 전체 여정 시간 범위 내의 모든 구간을 출발 시간 순으로 선택
    declare segments_cursor cursor for
        select seq
        from schedules_detail
        where schedules_seq = i_schedules_seq
          and departure_time >= v_journey_start_time
          and destination_time <= v_journey_end_time
        order by departure_time; -- ★ 출발 시간을 기준으로 정렬

    declare continue handler for not found set v_done = true;

    -- 회원 및 좌석 기본 정보 조회
    select seq into v_member_seq from member where member_id = i_member_id;
    select seq into v_seat_seq from seat where room_id = i_room_id and seat_id = i_seat_id;

    -- ### 핵심 로직: 여정의 시작 시간과 종료 시간 조회 ###
    -- 1. 사용자가 입력한 출발역에서 출발하는 시간
    select departure_time into v_journey_start_time
    from schedules_detail
    where schedules_seq = i_schedules_seq and departure = i_start_station;

    -- 2. 사용자가 입력한 도착역에 도착하는 시간
    select destination_time into v_journey_end_time
    from schedules_detail
    where schedules_seq = i_schedules_seq and destination = i_end_station;


    -- 트랜잭션 시작
    start transaction;

    -- 예매 정보(reservation) 우선 생성
    insert into reservation (member_seq, reservation_id, status)
    values (v_member_seq, concat('res-', date_format(now(), '%Y%m%d'), lpad(v_member_seq, 5, '0')), '예매 완료');
    set v_reservation_seq = last_insert_id();

    -- 커서를 열고 구간별로 좌석 상태 변경
    open segments_cursor;

    read_loop: loop
        fetch segments_cursor into v_schedules_detail_seq;
        if v_done then
            leave read_loop;
        end if;

        update seat_management
        set reservation_seq = v_reservation_seq, is_available = 'false'
        where seat_seq = v_seat_seq
          and schedules_detail_seq = v_schedules_detail_seq
          and is_available = 'true';

        -- 업데이트 실패 시(이미 예매된 좌석)
        if row_count() = 0 then
            set v_error_flag = 1;
            leave read_loop;
        end if;
    end loop;

    close segments_cursor;

    -- 최종 트랜잭션 처리
    if v_error_flag = 1 then
        select '예약 실패: 일부 구간의 좌석이 이미 예매되었거나 존재하지 않습니다.' as '결과';
        rollback;
    else
        select '예약 성공!' as '결과', v_reservation_seq as '새 예약번호';
        commit;
    end if;

end //

delimiter ;