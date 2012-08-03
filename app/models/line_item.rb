class LineItem < ActiveRecord::Base
	attr_accessible :name, :yr0, :yr1, :yr2, :yr3, :yr4, :yr5, :yr6, :yr7, :yr8, :yr9
	belongs_to :data_model, :polymorphic => true

	default_scope order: 'line_items.created_at ASC'

	scope :income_statement, lambda { |stock| income_statement(stock)}
	scope :balance_sheet, lambda { |stock| balance_sheet(stock)}
	scope :cash_flow, lambda { |stock| cash_flow(stock)}
	

	def five_yr_average
		return (self.yr0+self.yr1+self.yr2+self.yr3+self.yr4)/5
		
	end

	def copy_data(new_line)
		a = self.year_values
		b = new_line.year_array
		i=0
		a.each do |yr|
			new_line.update_attribute(b[i],a[i])
			i=i+1
		end
	end

	def sum!
		return (self.yr9+ self.yr8+ self.yr7+ self.yr6+ self.yr5+ self.yr4+ self.yr3+ self.yr2+ self.yr1+ self.yr0)
	end

	def year_array
		return [:yr9, :yr8, :yr7, :yr6, :yr5, :yr4, :yr3, :yr2, :yr1, :yr0]
	end

	def year_values
		return [self.yr9, self.yr8, self.yr7, self.yr6, self.yr5, self.yr4, self.yr3, self.yr2, self.yr1, self.yr0] 
	end

	def add!(x)
		a = self.year_array
		b = self.year_values
		i=0
		while i<a.length
			self.update_attribute(a[i],b[i]+x)
			i=i+1
		end
	end

	def multiply!(x)
		a = self.year_array
		b = self.year_values
		i=0
		while i<a.length
			self.update_attribute(a[i],b[i]*x)
			i=i+1
		end
	end

	def divide!(line_name)
		line = data_model.get_line(line_name)
		a = self.year_array
		b = self.year_values
		c = line.year_values
		i=0
		while i<a.length
			self.update_attribute(a[i],c[i]/b[i])
			i=i+1
		end
	end


	private
		
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
				"Total Net Income"]
			where(:name =>income_statement_lines, :data_model_id => stock.id, :data_model_type =>"Stock")
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
				"Total Equity"]
			where(:name =>balance_sheet_lines, :data_model_id => stock.id, :data_model_type =>"Stock")
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
				"Net Cash From Financing Activities"]
			where(:name => cash_flow_lines, :data_model_id => stock.id, :data_model_type =>"Stock")
		end

end
