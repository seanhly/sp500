select
	stock,
	date,
	cash_and_equivalents,
	cost_of_goods_sold,
	declare_date,
	record_date,
	payment_date,
	research_and_development,
	quarterly_revenue,
	sg_a_expense,
	shares_outstanding,
	total_assets,
	total_current_assets,
	total_current_liabilities,
	total_liabilities,
	total_operating_expenses
	/*
	frequency as dividend_frequency,
	divs_per_share,
	ttm_div_per_share,
	*/
from 'cash_and_equivalents.tsv'
full join 'cost_of_goods_sold.tsv' using (stock, date)
full join 'research_and_development.tsv' using (stock, date)
full join 'revenue.tsv' using (stock, date)
full join 'sga_expense.tsv' using (stock, date)
full join 'shares_outstanding.tsv' using (stock, date)
full join 'total_assets.tsv' using (stock, date)
full join 'total_current_assets.tsv' using (stock, date)
full join 'total_current_liabilities.tsv' using (stock, date)
full join 'total_liabilities.tsv' using (stock, date)
full join 'total_operating_expenses.tsv' using (stock, date)
;
/*
full join 'dividends.tsv' using (stock, date)
;
*/
