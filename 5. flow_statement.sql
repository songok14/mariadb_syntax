-- 흐름제어: case when, if, ifnull
-- if(a, b, c) -> a가 참이면 b, 거짓이면 c 반환
select id, if(name is null, '익명사용자', name) from author;

-- ifnull(a, b) -> a가 null이면 b 반환, 그렇지 않으면 a 반환
select id, ifnull(name, '익명사용자') from author;

-- case when 
select id,
case
    when name is null then '익명사용자'
    when name='hong1' then '홍길동'
    else name
end as name
from author;

-- 경기도에 위치한