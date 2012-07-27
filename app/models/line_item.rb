class LineItem < ActiveRecord::Base
	attr_accessible :name, :yr0, :yr1, :yr2, :yr3, :yr4, :start_year
	belongs_to :stock

	default_scope order: 'line_items.created_at ASC'

	scope :income_statement, lambda { |stock| income_statement(stock)}
	scope :balance_sheet, lambda { |stock| balance_sheet(stock)}
	scope :cash_flow, lambda { |stock| cash_flow(stock)}
	scope :all, lambda { |stock| all(stock)}

	private
		def self.all(stock)
			select('*')
		end
		def self.income_statement(stock)
			income_statement_lines = Array.new
			income_statement_lines = ["Operating Revenue",
				"Adjustments To Revenue",
				"Cost Of Sales",
				"Gross Operating Profit",
				"Research & Development (R&D) Expense",
				"Selling, General & Administrative (SG&A) Expense",
				"Advertising",
				"EBITDA",
				"Depreciation",
				"Depreciation (Unrecognized)",
				"Amortization",
				"Amortization Of Intangibles",
				"Interest Income",
				"Earnings From Equity Interest",
				"Other Income Net",
				"Income, Acquired In Process R&A",
				"Special Income Charges",
				"EBIT",
				"Interest Expense",
				"Income Taxes",
				"Minority Interest",
				"Pref. Securities Of Subsid. Trust",
				"Net Income (Discontinued Operations)",
				"Net Income (Total Operations)",
				"Extraordinary Income/Losses",
				"Income From Cum. Effect Of Acct. Change",
				"Income From Tax Loss Carryforward",
				"Other Gains/Losses",
				"Total Net Income",]
			where(self.arel_table[:name].in(income_statement_lines))
		end

		def self.balance_sheet(stock)
			balance_sheet_lines = Array.new
			balance_sheet_lines = ["Cash & Equivalents",
				"Restricted Cash",
				"Marketable Securities",
				"Receivables",
				"Inventories",
				"Prepaid Expenses",
				"Current Defered Income Taxes",
				"Other Current Assets",
				"Total Current Assets",
				"Total Fixed Assets",
				"Accumulated Depreciation",
				"Net Fixed Assets",
				"Intangibles",
				"Cost In Excess",
				"Non-Current Deferred Income Taxes",
				"Other Non-Current Assets",
				"Total Non-Current Assets",
				"Total Assets",
				"Accounts Payable",
				"Notes Payable",
				"Short-Term Debt",
				"Accrued Expenses",
				"Accrued Liabilities",
				"Deferred Revenues",
				"Current Deferred Income Taxes",
				"Other Current Liabilities",
				"Total Current Liabilities",
				"Long-Term Debt",
				"Capital Lease Obligations",
				"Deferred Income Taxes",
				"Other Non-Current Liabilities",
				"Minority Interest Liability",
				"Preferred Secur. Of Subsid. Trust",
				"Preferred Equity Outside Stock Equity",
				"Total Liabilities",
				"Total Equity",]
			where(self.arel_table[:name].in(balance_sheet_lines))
		end

		def self.cash_flow(stock)
			cash_flow_lines = Array.new
			cash_flow_lines = ["Total Net Income",
				"Depreciation",
				"Deferred Income Taxes",
				"Operating Gains",
				"Extraordinary Gains",
				"(Increase) Decrease In Receivables",
				"(Increase) Decrease In Inventories",
				"(Increase) Decrease In Prepaid Expenses",
				"(Increase) Decrease In Other Current Assets",
				"Decrease (Increase) In Payables",
				"Decrease (Increase) In Other Current Liabilities",
				"Decrease (Increase) In Other Working Capital",
				"Other Non-Cash Items",
				"Net Cash From Continuing Operations",
				"Purchase Of Property, Plant & Equipment",
				"Acquisitions",
				"Net Cash From Investing Activities",
				"Issuance Of Debt",
				"Issuance Of Capital Stock",
				"Repayment Of Long-Term Debt",
				"Repurchase Of Capital Stock",
				"Payment Of Cash Dividends",
				"Other Financing Charges, Net",
				"Cash From Discontinued Financing Activities",
				"Net Cash From Financing Activities",]
			where(self.arel_table[:name].in(cash_flow_lines))
		end

end
