select
 	stock,
	date,
	annual_revenue as revenue,
	annual_cash_and_equivalents as cash_and_equivalents,
	annual_cost_of_goods_sold as cost_of_goods_sold,
	annual_research_and_development as research_and_development,
	annual_revenue as revenue,
	annual_sg_a_expense as sg_a_expense,
	annual_shares_outstanding as shares_outstanding,
	annual_total_assets as total_assets,
	annual_total_current_assets as total_current_assets,
	annual_total_current_liabilities as total_current_liabilities,
	annual_total_liabilities as total_liabilities,
	annual_total_operating_expenses as total_operating_expenses
from 'cash_and_equivalents_annual.tsv'
full join 'cost_of_goods_sold_annual.tsv' using (stock, date)
full join 'research_and_development_annual.tsv' using (stock, date)
full join 'revenue_annual.tsv' using (stock, date)
full join 'sga_expense_annual.tsv' using (stock, date)
full join 'shares_outstanding_annual.tsv' using (stock, date)
full join 'total_assets_annual.tsv' using (stock, date)
full join 'total_current_assets_annual.tsv' using (stock, date)
full join 'total_current_liabilities_annual.tsv' using (stock, date)
full join 'total_liabilities_annual.tsv' using (stock, date)
full join 'total_operating_expenses_annual.tsv' using (stock, date)
order by stock, date;
