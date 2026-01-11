with target as (
	select 'BAC' as target
),
data as (
	select * from 'data.csv'
	where stock in (
		'FITB', 'JPM', 'LNC', 'ZION', 'RJF', 'HBAN', 'USB', 'RF',
		'BAC', 'KEY', 'PRU', 'MET', 'CFG'
	)
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
),
engineered_features as (
	select
		f2.Stock stock,
		f2.Date date,
		f2.seq,
		f2.volume volume,
		(f2.volume - f1.volume) / f1.volume volume_change_1d,
		(f2.mean - f1.mean) / f1.mean mean_change_1d,
		(f2.mean - f1.close) / f1.close close_to_mean_1d,
		(f2.volume * f2.mean - f1.volume * f1.mean) / (f1.volume * f1.mean) mean_volume_value_change_1d,
		(f2.high - f1.low) / f1.low low_to_high_1d,
		(f2.low - f1.high) / f1.high high_to_low_1d,
		(f2.open - f1.open) / f1.open open_to_open_1d,
		(f2.close - f1.close) / f1.close close_to_close_1d,
		(f2.low - f1.low) / f1.low low_to_low_1d,
		(f2.high - f1.high) / f1.high high_to_high_1d,
		(f2.open - f1.close) / f1.Close overnight_change
	from feature_source f2
	join feature_source f1 on f1.Stock = f2.Stock and f1.Seq = f2.Seq - 1
),
feature_table as (
	select
		label.date,
		context.stock || (context.seq - label.seq) as feature_name,
		context.* exclude (seq, date, stock)
	from engineered_features label
	join engineered_features context
		on context.seq between label.seq - 10 and label.seq - 1
	join target on 1
	where label.stock = target
),
feature_counts as (
	select date, count(1) feature_count
	from feature_table
	group by date
),
feature_count_counts as (
	select feature_count, count(1) c
	from feature_counts
	group by feature_count
),
max_feature_count as (
	select feature_count from feature_count_counts where c = (select max(c) from feature_count_counts)
),
data_rich_dates as (
	select date from feature_counts where feature_count = (select feature_count from max_feature_count)
),
value_features as (
	select
		date,
		feature_name || '.' ||
		unnest([
			--'volume',
			'volume_change_1d',
			'mean_change_1d',
			'mean_volume_value_change_1d',
			'low_to_high_1d',
			'high_to_low_1d',
			'open_to_open_1d',
			'close_to_close_1d',
			'low_to_low_1d',
			'high_to_high_1d',
			'overnight_change',
			--'close_to_mean_1d'
		]) as key,
		unnest([
			--volume,
			volume_change_1d,
			mean_change_1d,
			mean_volume_value_change_1d,
			low_to_high_1d,
			high_to_low_1d,
			open_to_open_1d,
			close_to_close_1d,
			low_to_low_1d,
			high_to_high_1d,
			overnight_change,
			--close_to_mean_1d
		]) as value
	from feature_table natural join data_rich_dates
),
date_features as (
	select
		date, 
		unnest([
			'dow',
			'month',
			'dom'
		]) as key,
		unnest([
			dayofweek(date),
			month(date),
			dayofmonth(date)
		]) as value
	from data_rich_dates
	group by date
),
named_features as (
	select * from value_features union all select * from date_features
),
features as (
	select date, 'x' || lpad((dense_rank() over (order by key) - 1)::text, 4, '0') i, value
	from named_features
),
feature_matrix as (
	pivot features on i using sum(value)
)
select
	y.close_to_mean_1d y,
	x.*
from feature_matrix x
join engineered_features y using (date)
join target on 1
where y.stock = target
--and abs(y.close_to_mean_1d) > 0.001
order by date desc
--select * from named_features
;
