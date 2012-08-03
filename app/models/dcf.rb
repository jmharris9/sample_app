class Dcf < ActiveRecord::Base
	attr_accessible :name, :growth_rate, :discount_rate
	has_many :line_items, as: :data_model, dependent: :destroy
	belongs_to :stock
	

	def init
		a_ray = Array.new
		line_array = Array.new
		a_ray=[
		"Total Current Assets",
		"Total Current Liabilities",
		"Total Liabilities",
		"Total Equity",
		"Total Common Shares Out",
		"Total Net Income",
		"Depreciation",
		"(Increase) Decrease In Receivables",
		"(Increase) Decrease In Inventories",
		"(Increase) Decrease In Prepaid Expenses",
		"(Increase) Decrease In Other Current Assets",
		"Decrease (Increase) In Payables",
		"Decrease (Increase) In Other Current Liabilities",
		"Decrease (Increase) In Other Working Capital",
		"Other Non-Cash Items",
		"Purchase Of Property, Plant & Equipment",
		"Owners' Earnings",
		"CROIC",
		"Total Common Shares Out",
		"Cash & Equivalents",
		"Net Fixed Assets",
		"Total Liabilities",]
		a_ray.each do |name|
			line_array<<stock.get_line(name)
		end
		
		return line_array
	end

	def get_line(line_name)
		line = line_items.where(:name => line_name)
		return line[0]
	end

###################### DISCOUNTED FREE CASH FLOW CODE ######################
	def run_dcf
		tr = 1.05
		fc = self.line_items.new(:yr0=>0,:yr1=>0,:yr2=>0,:yr3=>0,:yr4=>0, :yr5=>0,:yr6=>0,:yr7=>0,:yr8=>0,:yr9=>0)
		fc1 = self.line_items.new(:yr0=>0,:yr1=>0,:yr2=>0,:yr3=>0,:yr4=>0, :yr5=>0,:yr6=>0,:yr7=>0,:yr8=>0,:yr9=>0)
		fc.save
		fc1.save
		oe = stock.get_line("Owners' Earnings").yr0
		rate = (1+self.growth_rate/100)/(1+self.discount_rate/100)
		trate = (tr/(1+self.discount_rate/100))
		shares = stock.get_line("Total Common Shares Out").yr0

		self.value = (((oe*(1-(rate**11))/(1-rate)))  + (oe*(1-(trate**21))/(1-trate))-(oe*(1-(trate**10))/(1-trate)))/shares
		self.save
		gr = 1+self.growth_rate/100
		dr = 1 +self.discount_rate/100
		a = fc.year_array
		b = fc1.year_array
		i=0
		value = 0
		while i<a.length
			cf= oe*gr**(i+1)
			tcf = oe*(gr**(10))*(tr**(i+1))
			fc.update_attribute(a[i], cf)
			fc1.update_attribute(b[i], tcf)
			value = value + cf/(dr**(i+1)) + (tcf/(dr**(i+11)))
			i=i+1
		end

		fc.name = "Future Cash at #{self.growth_rate}%"
		fc.save
		fc1.name = "Future Cash at 5%"
		fc1.save
		return value/shares
	end

	def stock_data
		a_ray = Array.new
		line_array = Array.new
		a_ray=[
		"Total Net Income",
		"Purchase Of Property, Plant & Equipment",
		"Owners' Earnings",
		"Total Common Shares Out",
		"CROIC",
		"Diluted EPS - Total"
		]
		a_ray.each do |name|
			line_array<<stock.get_line(name)
		end
		return line_array
	end

	def projection
		a_ray = Array.new
		line_array = Array.new
		a_ray=[
		"Future Cash at #{self.growth_rate}%",
		"Future Cash at 5%"]
		a_ray.each do |name|
			line_array<<self.get_line(name)
		end
		return line_array
	end

	def discount
		return (self.value-stock.price)*100/stock.price
	end

	def reverse_dcf

	end

###################### BEN GRAHAM CODE ######################
	def ben_graham_number
		a_ray = Array.new
		line_array = Array.new
		a_ray=[
		"EPS 10yr",
		"EPS 5yr"]
		a_ray.each do |name|
			line_array<<self.get_line(name)
		end
		return line_array
	end

	def eps_averages
		eps = stock.get_line("Diluted EPS - Total").year_values
		eps10 = self.line_items.new(:yr0=>0,:yr1=>0,:yr2=>0,:yr3=>0,:yr4=>0, :yr5=>0,:yr6=>0,:yr7=>0,:yr8=>0,:yr9=>0)
		eps10.save
		a = eps10.year_array.reverse!
		eps5 = self.line_items.new(:yr0=>0,:yr1=>0,:yr2=>0,:yr3=>0,:yr4=>0, :yr5=>0,:yr6=>0,:yr7=>0,:yr8=>0,:yr9=>0)
		eps5.save
		b = eps5.year_array.reverse!
		#9/4 year time frame
		i=0
		while i<2
			if eps[i] <0 or eps[i+8] <0
				eps10.update_attribute(a[9-i],0)
			else
				eps10.update_attribute(a[9-i],(((eps[i+8]/eps[i])**(1.0/8))-1)*100)
			end
			if eps[i+4] <0 or eps[i+8] <0
				eps5.update_attribute(a[9-i],0)
			else
				eps5.update_attribute(a[9-i],(((eps[i+8]/eps[i+4])**(1.0/4))-1)*100)
			end
			i=i+1
		end

		#8/3 year time frame
		i=0
		while i < 3 
			if eps[i]<0 or eps[i+7] <0
				eps10.update_attribute(a[7-i],0)
			else
				eps10.update_attribute(a[7-i], (((eps[i+7]/eps[i])**(1.0/7))-1)*100)
			end
			if eps[i+4] <0 or eps[i+7] <0
				eps5.update_attribute(a[7-i],0)
			else
				eps5.update_attribute(a[7-i],(((eps[i+7]/eps[i+4])**(1.0/3))-1)*100)
			end
			i=i+1
		end

		#6/1 year time frame
		i = 0
		while i < 5
			if eps[i]<0 or eps[i+5] <0
				eps10.update_attribute(a[4-i],0)
			else
				eps10.update_attribute(a[4-i] ,((eps[i+5]/eps[i])**(1.0/5)-1)*100)
			end
			if eps[i+4] <0 or eps[i+5] <0
				eps5.update_attribute(a[4-i],0)
			else
				eps5.update_attribute(a[4-i],((eps[i+5]/eps[i+4])-1)*100)
			end
			i=i+1
		end

		eps10.name = "EPS 10yr"
		eps10.save
		eps5.name = "EPS 5yr"
		eps5.save
		self.save
	end

	def get_AAA_rate
		yahoo_url = "http://finance.yahoo.com/bonds/composite_bond_rates"
		yahoo_doc = Nokogiri::HTML(open(yahoo_url))
		ytext = yahoo_doc.css(":nth-child(4) tr:nth-child(9) td:nth-child(5)").first.text
		return ytext.to_f
	end

	def bg_calc
		bond_rate = self.get_AAA_rate
		eps = stock.get_line("Diluted EPS - Total").yr0
		growth = self.get_line("EPS 10yr").sum!/10
		return eps*(7+1.5*growth)*4.4/bond_rate
	end
###################### Net Net Asset Value ######################


	def nnav_data
		reciev = self.line_items.new(:yr0=>0,:yr1=>0,:yr2=>0,:yr3=>0,:yr4=>0, :yr5=>0,:yr6=>0,:yr7=>0,:yr8=>0,:yr9=>0)
		stock.get_line("Receivables").copy_data(reciev)
		reciev.multiply!(0.75)
		inventory = self.line_items.new(:yr0=>0,:yr1=>0,:yr2=>0,:yr3=>0,:yr4=>0, :yr5=>0,:yr6=>0,:yr7=>0,:yr8=>0,:yr9=>0)
		stock.get_line("Inventories").copy_data(inventory)
		inventory.multiply!(0.5)
		nnav_array= [stock.get_line("Cash & Equivalents"),
		stock.get_line("Restricted Cash"),
		stock.get_line("Marketable Securities"),
		reciev,
		inventory]
		summed = self.line_items.new(:yr0=>0,:yr1=>0,:yr2=>0,:yr3=>0,:yr4=>0, :yr5=>0,:yr6=>0,:yr7=>0,:yr8=>0,:yr9=>0)
		a=summed.year_array
		nnav_array.each do |item|
			i=0
			b = summed.year_values
			c = item.year_values
			while i<a.length
				summed.update_attribute(a[i], b[i] + c[i])
				i=i+1
			end
		end
		summed.update_attribute(:name, "NNAV")
		summed.save
		liabs = stock.get_line("Total Liabilities")
		shares = stock.get_line("Total Common Shares Out").yr9
		i=0
		a = summed.year_array
		b = summed.year_values
		c = liabs.year_values
		while i<a.length
			summed.update_attribute(a[i], (b[i]-c[i]))
			i=i+1
		end
		summed.multiply!(1/shares)
		summed.save
	end

	def nnav
		a_ray = Array.new
		line_array = Array.new
		a_ray=[
		"Cash & Equivalents",
		"Restricted Cash",
		"Marketable Securities"
		]
		a_ray.each do |name|
			line_array<<stock.get_line(name)
		end
		line_array<<self.get_line("NNAV")
		return line_array
		line_array<<stock.get_line("NNAV Receivables")
		line_array<<stock.get_line("NNAV Inventories")
	end

	def p_score
		p_score = self.line_items.new(:yr0=>0,:yr1=>0,:yr2=>0,:yr3=>0,:yr4=>0, :yr5=>0,:yr6=>0,:yr7=>0,:yr8=>0,:yr9=>0)
		p = p_score.year_array
		p_value = p_score.year_values
		net_income = stock.get_line("Total Net Income").year_values
		cash_from_ops = stock.get_line("Net Cash From Continuing Operations").year_values
		roa = stock.get_line("Return On Assets (ROA)").year_values
		long_term_debt= stock.get_line("Long-Term Debt").year_values
		assets = stock.get_line("Total Assets").year_values
		current_ratio = stock.get_line("Current Ratio").year_values
		shares = stock.get_line("Total Common Shares Out").year_values
		gross_margin = stock.get_line("Gross Margin").year_values
		asset_turn = stock.get_line("Asset Turnover").year_values
		i=0
		while i<9
			x=0
			if net_income[i]>0
				x+=1
			end
			if cash_from_ops[i]>0
				x+=1
			end
			if roa[i]>roa[i+1]
				x+=1
			end
			if cash_from_ops[i]>net_income[i]
				x+=1
			end
			if long_term_debt[i]/assets[i] <long_term_debt[i+1]/assets[i+1]
				x+=1
			end
			if current_ratio[i]<current_ratio[i+1]
				x+=1
			end
			if shares[i]<shares[i+1]
				x+=1
			end
			if gross_margin[i]>gross_margin[i+1]
				x+=1
			end
			if asset_turn[i]>asset_turn[i+1]
				x+=1
			end
			i+=1
			p_score.update_attribute(p[i],x)
		end
		p_score.update_attribute(:name,"Piotroski Formula")
	end

	def altman_z
		altz = self.line_items.new(:yr0=>0,:yr1=>0,:yr2=>0,:yr3=>0,:yr4=>0, :yr5=>0,:yr6=>0,:yr7=>0,:yr8=>0,:yr9=>0)
		nonz= self.line_items.new(:yr0=>0,:yr1=>0,:yr2=>0,:yr3=>0,:yr4=>0, :yr5=>0,:yr6=>0,:yr7=>0,:yr8=>0,:yr9=>0)
		a = altz.year_array
		b = nonz.year_array
		working_cap = stock.get_line("Working Capital").year_values
		total_assets = stock.get_line("Total Assets").year_values
		retained_earnings = stock.get_line("Retained Earnings").year_values
		ebidta = stock.get_line("EBITDA").year_values
		revenue = stock.get_line("Operating Revenue").year_values
		shares = stock.get_line("Total Common Shares Out").year_values
		total_liabs = stock.get_line("Total Liabilities").year_values
		i=0
		while i<10
			x1 = working_cap[i]/total_assets[i]
			x2 = retained_earnings[i]/total_assets[i]
			x3 = ebidta[i]/total_assets[i]
			x4 = stock.price*shares[i]/total_liabs[i]
			x5 = revenue[i]/total_assets[i]
			altz.update_attribute(a[i], 1.2*x1 + 1.4*x2 + 3.3*x3 + 0.6*x4 + 1.0*x5)
			nonz.update_attribute(b[i], 6.56*x1 + 3.26*x2 + 6.72*x3 + 1.05*x4)
			i+=1
		end
		altz.update_attribute(:name, "Altman Z (manufacturing)")
		nonz.update_attribute(:name, "Altman Z (nonmanufacturing)")
	end

	def epv
	end

	def ben_m
		ben_m_score = self.line_items.new(:yr0=>0,:yr1=>0,:yr2=>0,:yr3=>0,:yr4=>0, :yr5=>0,:yr6=>0,:yr7=>0,:yr8=>0,:yr9=>0)
		ben_five_score = self.line_items.new(:yr0=>0,:yr1=>0,:yr2=>0,:yr3=>0,:yr4=>0, :yr5=>0,:yr6=>0,:yr7=>0,:yr8=>0,:yr9=>0)
		a = ben_m_score.year_array
		b = ben_five_score.year_array
		working_cap = stock.get_line("Working Capital").year_values
		total_assets = stock.get_line("Total Assets").year_values
		cash = stock.get_line("Cash & Equivalents").year_values
		sales = stock.get_line("Operating Revenue").year_values
		debt = stock.get_line("Total Liabilities").year_values
		sga = stock.get_line("Selling, General & Administrative (SG&A) Expense").year_values
		depreciation = stock.get_line("Depreciation").year_values
		ppe  = stock.get_line("Total Fixed Assets").year_values
		gross_margin = stock.get_line("Gross Margin").year_values
		accounts_recievable  = stock.get_line("Accounts Receivable").year_values
		current_assets = stock.get_line("Total Current Assets").year_values
		i=0
		while i<9
			levi = (debt[i]/total_assets[i])/(debt[i+1]/total_assets[i+1])
			sgai = sga[i]/sga[i+1]
			depi = depreciation[i+1]/depreciation[i]
			sgi = sales[i]/sales[i+1]
			aqi = ((total_assets[i]-ppe[i]-current_assets[i])/total_assets[i]) / ((total_assets[i+1]-ppe[i+1]-current_assets[i])/total_assets[i+1])
			gmi = gross_margin[i+1]/gross_margin[i]
			dsri = (365/(sales[i]/accounts_recievable[i])) / (365/(sales[i+1]/accounts_recievable[i+1]))
			tata = (working_cap[i] - cash[i] - depreciation[i] - working_cap[i+1] + cash[i+1] + depreciation[i+1]) / total_assets[i]
			ben_m_score.update_attribute(a[i], -4.84 + 0.92*dsri + 0.528*gmi + 0.404*aqi +0.892*sgi + 0.115*depi - 0.172*sgai + 4.679*tata -0.326*levi)
			ben_five_score.update_attribute(b[i], -6.065 + 0.823*dsri + 0.906*gmi + 0.593*aqi +0.717*sgi + 0.107*depi )
			i+=1
		end
		ben_m_score.update_attribute(:name, "Beneish M Score - 8 variable")
		ben_five_score.update_attribute(:name, "Beneish M Score - 5 variable")
	end

	def epv
		rd = stock.get_line("Research & Development (R&D) Expense").year_values
		cash = stock.get_line("Cash & Equivalents").year_values
		sales = stock.get_line("Operating Revenue").year_values
		total_assets = stock.get_line("Total Assets").year_values
		sgasales = stock.get_line("SG&A As % Of Revenue").year_values
		shares = stock.get_line("Total Common Shares Out").year_values
	end
end



























