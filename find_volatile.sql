with target as (
	select 'BAC' as target
),
data as (
	select * from 'data.csv'
),
dates as (
	select Date, dense_rank() over (order by Date) seq from data group by Date
),
feature_source as (
	select
		* exclude ("Adjusted Close"),
		case when Open = 0 then 0 else (Close - Open) / Open end open_to_close,
		case when Open = 0 then 0 else (High - Open) / Open end open_to_high,
		least(Low, High) / High as low_high_ratio,
		(Open + Close + Low + High) / 4 as mean
	from data d
	natural join dates
	where Open is not NULL
)
select
	Stock stock,
	stddev(open_to_close)
from feature_source
group by stock
having avg(Volume) * (avg(Open) + avg(Close) + avg(High) + avg(Low)) / 4 > 100000000
order by stddev(open_to_close)
;
