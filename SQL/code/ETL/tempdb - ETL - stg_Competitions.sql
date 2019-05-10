use tempdb
go

;with cte_trim_fields
as
(
    select ltrim(rtrim(F1)) as F1,
	       ltrim(rtrim(F2)) as F2,
		   ltrim(rtrim(F3)) as F3,
		   ltrim(rtrim(F4)) as F4,
		   ltrim(rtrim(F5)) as F5,
		   ltrim(rtrim(F6)) as F6,
		   ltrim(rtrim(F7)) as F7,
		   id
	from stg_Competitions
),
cte_list_of_group_discipline
as
(
    select c.id, 
         c.F2 as group_discipline
    from cte_trim_fields c
    join cte_trim_fields c1 on c.id+1 = c1.id
    join cte_trim_fields c2 on c.id+2 = c2.id
    where (c1.F1 = '1' and (charindex('-', c.F2)<>0)) or 
          (c2.F1 = '1' and (charindex('-', c.F2)<>0))
),
cte_list_of_ranges
as
(
    select id start_id, 
	       lead(id) over(order by id) end_id
    from cte_list_of_group_discipline
),
cte_pivoted
as
(
	select c.*, gd.group_discipline
	from stg_Competitions c
	join cte_list_of_ranges rr on c.id between rr.start_id and case when rr.end_id-1 is not null then rr.end_id-1 else (select count(1) from stg_Competitions) end
	join cte_list_of_group_discipline gd on gd.id = rr.start_id
),
cte_transformed
as
(
	select 
	       F1 as place,

		   iif(charindex(' ', F2)<>0, left(F2, charindex(' ', F2) - 1), F2) as last_name,
		   iif(charindex(' ', F2)<>0, right(F2, len(F2) - charindex(' ', F2)), null) as first_name,

		   iif(len(F3)=2, iif(left(F3, 1) in ('8','9'), '19'+F3,'20'+F3), F3) as birth_year,

		   iif(charindex(',', F4)<>0, left(F4, charindex(',', F4) - 1), F4) as city,
		   iif(charindex(',', F4)<>0, right(F4, len(F4) - charindex(',', F4)), null) as team,
		   
		   F5 as country,	 
		  
		   iif(charindex('D', F6)=0, iif(len(F6)=2, F6+'.00', F6), null) as result,
		   iif(charindex('D', F6)<>0, F6, null) as disc,
		   
		   F7 as points,
   		   
		   rtrim(left(group_discipline, len(group_discipline) - charindex('-', reverse(group_discipline)))) as athlete_group,
		   ltrim(right(group_discipline, charindex('-', reverse(group_discipline)) - 1)) as discipline,

		   id
	from cte_pivoted
	where F1 is not null
),
cte_parse_time
as
(
    select left(result, len(result) - patindex('%[:,.]%', reverse(result))) left_to_parse, 
	       try_parse(right(result, patindex('%[:,.]%', reverse(result)) - 1) as int) token,
		   it = 1,
		   id
    from cte_transformed
    union all
    select iif(patindex('%[:,.]%', reverse(left_to_parse)) <> 0, left(left_to_parse, len(left_to_parse) - patindex('%[:,.]%', reverse(left_to_parse))), '0') left_to_parse, 
	       try_parse(iif(patindex('%[:,.]%', reverse(left_to_parse)) <> 0, right(left_to_parse, patindex('%[:,.]%', reverse(left_to_parse)) - 1), left_to_parse) as int) token,
		   it = it + 1,
		   id
    from cte_parse_time
	where it < 4 	
), 
cte_cleaned_and_formatted
as
(
    select try_parse(place as int) place,
		   left(last_name, len(last_name) - charindex(' ', reverse(last_name))) last_name,
	       left(first_name, len(first_name) - charindex(' ', reverse(first_name))) first_name,
		   try_parse(birth_year as int) birth_year,
		   city,
		   replace(team, '"', '') team,
		   country,
		   timefromparts(h.token, m.token, s.token, ms.token, 2) result,
		   disc,
		   try_parse(points as int) points,		   
		   athlete_group,			   
		   try_parse(left(discipline, charindex(' ', discipline)) as int) distance,
	       right(discipline, len(discipline) - charindex(' ', discipline) ) as style,
		   t.id
	from cte_transformed t
	join cte_parse_time h on t.id = h.id and h.it = 4
	join cte_parse_time m on t.id = m.id and m.it = 3
	join cte_parse_time s on t.id = s.id and s.it = 2
	join cte_parse_time ms on t.id = ms.id and ms.it = 1
)
select * from cte_cleaned_and_formatted
