-- 특정 역의 전광판 출력
select sd.departure_time as '출발시간', sd.destination as '목적지', t.type as '열차종류', 
    t.train_id as '열차번호', std.track as '승강장' from schedules_detail sd
left join schedules s on sd.schedules_seq = s.seq
left join train t on s.train_seq = t.seq
left join station_detail std on sd.station_detail_seq = std.seq
-- 여기에서 원하는 출발역의 이름을 지정합니다.
where sd.departure = '테스트1역' order by sd.departure_time;

-- 운행 상세 정보 출력(schedules_detail.seq를 조회 -> sd.seq를 기반으로 남은좌석 선택 -> 예약 프로시저로 예약)
-- 사용자 입력 값 (출발지, 도착지, 날짜)
set @departure_station = '테스트10역';
set @destination_station = '테스트29역';
set @departure_date = '2025-06-10';

select
    sd.seq as '스케줄상세_seq', 
    sd.departure_time as '출발시간',
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
-- 여기까지
-- 예매 가능한 좌석 수를 세기 위한 조인 (서브쿼리 사용)
left join (
    select
        schedules_detail_seq,
        count(*) as cnt
    from
        seat_management
    where
        is_available = 'true'
    group by
        schedules_detail_seq
) as available_seats on sd.seq = available_seats.schedules_detail_seq
where
    sd.departure = @departure_station
    and sd.destination = @destination_station
    and date(sd.departure_time) = @departure_date
order by
    sd.departure_time;


-- 남은 좌석 확인
-- 조회할 운행 스케줄의 id를 지정
set @schedule_detail_seq_to_view = 22;

select
    s.room_id as '객실',
    s.seat_id as '좌석번호',
    sm.price as '가격'
from
    -- 좌석의 예매 상태와 가격 정보가 있는 seat_management를 기준으로
    seat_management as sm
join
    -- 좌석의 실제 이름(객실, 좌석번호)을 가져오기 위해 seat 테이블과 조인
    seat as s on sm.seat_seq = s.seq
where
    -- 사용자가 선택한 바로 그 운행 스케줄에 해당하는 정보만 필터링
    sm.schedules_detail_seq = @schedule_detail_seq_to_view
    -- 그리고 '예매 가능한' 상태의 좌석만 필터링
    and sm.is_available = 'true'
order by
    -- 보기 좋게 객실, 좌석번호 순으로 정렬
    s.room_id, s.seat_id;


-- 좌석 예약 프로시저
delimiter //

create procedure seat_reservation(
    in member_id varchar(255),            -- 입력값 1: 회원 id
    in schedule_detail_seq bigint,        -- 입력값 2: 운행 상세 id
    in room_id varchar(10),               -- 입력값 3: 객실 번호
    in seat_id varchar(10)                -- 입력값 4: 좌석 번호
)
begin
    declare v_member_seq bigint;
    declare v_seat_seq bigint;
    declare v_new_reservation_seq bigint;

    -- 입력 값을 기반으로 각 테이블의 pk (seq)를 조회
    select seq into v_member_seq from member where id = p_member_id;
    select seq into v_seat_seq from seat where room_id = p_room_id and seat_id = p_seat_id;

    -- 트랜잭션 시작
    start transaction;

    -- 예매 정보 생성
    insert into reservation (member_seq, reservation_id, status)
    values (v_member_seq, concat('res-', uuid()), '예매 완료');

    -- 방금 생성된 예매의 고유 pk (`reservation.seq`) 가져오기
    set v_new_reservation_seq = last_insert_id();

    -- 좌석 상태 변경
    update seat_management
    set
        reservation_seq = v_new_reservation_seq,
        is_available = 'false'
    where
        seat_seq = v_seat_seq
        and schedules_detail_seq = p_schedule_detail_seq
        and is_available = 'true';

    -- if문이 이제 프로시저 안이라서 정상 작동함
    if row_count() = 0 then
        -- 업데이트에 실패하면 (이미 예약된 좌석이면) 롤백
        select '예약 실패: 해당 좌석은 이미 예매되었거나 존재하지 않습니다.' as '결과';
        rollback;
    else
        -- 업데이트 성공 시 커밋
        select '예약 성공!' as '결과', v_new_reservation_seq as '새 예약번호';
        commit;
    end if;

end //

-- 구분자 원복
delimiter ;