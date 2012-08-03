require 'rubygems'
require 'nokogiri'
require 'open-uri'

class Stock < ActiveRecord::Base
	attr_accessible :symbol, :name, :price, :start_year
	belongs_to :user
	has_many :line_items, as: :data_model, dependent: :destroy
	has_many :dcfs, dependent: :destroy
	scope :search, lambda { |val|  where("symbol LIKE ?", "%#{val}%") }

	def get_line(line_name)
		line = line_items.where(:name => line_name)
		return line[0]
	end

	def sum(array)
		summed = self.line_items.new(:yr0=>0,:yr1=>0,:yr2=>0,:yr3=>0,:yr4=>0, :yr5=>0,:yr6=>0,:yr7=>0,:yr8=>0,:yr9=>0)
		a = summed.year_array
		array.each do |item|
			i=0
			line = self.get_line(item)
			b = summed.year_values
			c = line.year_values
			while i<a.length
				summed.update_attribute(a[i], b[i] + c[i])
				i=i+1
			end
		end
		return summed
	end

	def subtract!(x,y)
		line1 = self.get_line(x)
		line2 = self.get_line(y)
		i=0
		a = line1.year_array
		b = line1.year_values
		c = line2.year_values
		while i<a.length
			line1.update_attribute(a[i], b[i]-c[i])
			i=i+1
		end
	end

	def duplicate_line(line_name, new_name)
		line = get_line(line_name)
		new_line = line.dup
		new_line.name= new_name
		return line
	end

	def grab_data
		
		symbol = self.symbol

		# initail website call for present year
		url1 = "http://www.advfn.com/p.php?pid=financials&btn=s_ok&mode=annual_reports&symbol=#{symbol}&s_ok=OK&start_date="
		doc = Nokogiri::HTML(open(url1))

		yr = doc.at_css("tr:nth-child(2) .s:nth-child(6)")
		yr = yr.text
		yr = yr[0..3]
		year = yr.to_i
		self.update_attribute(:start_year, year)

		#if not, readjust to most recent data available (5 year period)

		#get 5-10 year period history
		url2 = "http://www.advfn.com/p.php?pid=financials&btn=s_ok&mode=annual_reports&symbol=#{symbol}&s_ok=OK&start_date=#{year-2002}"
		doc2 = Nokogiri::HTML(open(url2))
		#set stock name and get price
		name = doc.at_css("h1").text
		self.update_attribute(:name, name)
		self.get_price

		#screen scraping
		b = Array.new
		b = ["12",
			"14",
			"15",
			"17",
			"18",
			"19",
			"20",
			"21",
			"23",
			"24",
			"25",
			"26",
			"27",
			"29",
			"30",
			"31",
			"32",
			"35",
			"36",
			"37",
			"39",
			"40",
			"41",
			"44",
			"45",
			"46",
			"47",
			"48",
			"49",
			"50",
			"73",
			"83",
			"84",
			"85",
			"86",
			"89",
			"96",
			"97",
			"98",
			"99",
			"100",
			"106",
			"108",
			"109",
			"110",
			"111",
			"112",
			"113",
			"114",
			"115",
			"118",
			"119",
			"120",
			"121",
			"122",
			"123",
			"124",
			"125",
			"126",
			"127",
			"128",
			"129",
			"130",
			"131",
			"132",
			"133",
			"135",
			"141",
			"145",
			"149",
			"156",
			"168",
			"169",
			"170",
			"171",
			"172",
			"173",
			"174",
			"175",
			"176",
			"177",
			"178",
			"179",
			"186",
			"187",
			"192",
			"194",
			"195",
			"196",
			"197",
			"198",
			"199",
			"200",
			"201",
			"236",
			"242",
			"245",
			"286",]
		b.each do |line|
			#set line name
			@line_item = self.line_items.new
			@line_item.save
			line_name = doc.at_css("tr:nth-child(#{line}) :nth-child(1)").text
			line_name=line_name.gsub!(/\b[a-z0-9-_]/i){|l| l.upcase}
			@line_item.update_attribute(:name, line_name)
			#set line values
			a = Array.new
			a = @line_item.year_array
			i=0
			#doc2 is the 5-10 yr data
			doc2_array = doc2.css("tr:nth-child(#{line}) :nth-child(n+2)")
			doc.css("tr:nth-child(#{line}) :nth-child(n+2)").each do |item|
				word=item.text
				word.delete!(",")
				number = word.to_f
				@line_item.update_attribute(a[(i+5)], number)
				@line_item.save
				web_word = doc2_array[i]
				word2 = web_word.text
				word2.delete!(",")
				number2 = word2.to_f
				@line_item.update_attribute(a[i], number2)
				@line_item.save
				i=i+1
			end
		end
	end

	def get_price
		yahoo_url = "http://finance.yahoo.com/q?s=#{symbol}&ql=1"
		yahoo_doc = Nokogiri::HTML(open(yahoo_url))
		s = self.symbol.downcase
		ytext = yahoo_doc.css("#yfs_l84_#{s}").first.text
		ynumber = ytext.to_f
		self.update_attribute(:price ,ynumber)
	end 

	def income_statement_feed
		LineItem.income_statement(self)
	end

	def balance_sheet_feed
		LineItem.balance_sheet(self)
	end

	def cash_flow_feed
		LineItem.cash_flow(self)
	end

	def owners_earnings
		income = 'Total Net Income'
		depreciation = 'Depreciation'
		d_working_cap = self.line_items.new
		change_in_working = Array.new
		change_in_working = ["(Increase) Decrease In Receivables",
		"(Increase) Decrease In Inventories",
		"(Increase) Decrease In Prepaid Expenses",
		"(Increase) Decrease In Other Current Assets",
		"Decrease (Increase) In Payables",
		"Decrease (Increase) In Other Current Liabilities",
		"Decrease (Increase) In Other Working Capital",]
		d_working_cap = self.sum(change_in_working)
		d_working_cap.name = "Change in Working Capital" 
		d_working_cap.save
		other_non_cash = ('Other Non-Cash Items')
		ppe = self.get_line('Purchase Of Property, Plant & Equipment')
		av_ppe = ppe.five_yr_average
		b = Array.new
		b = [income, depreciation, d_working_cap.name, other_non_cash]
		oe = self.sum(b)
		oe.add!(av_ppe)
		oe.name = "Owners' Earnings"
		oe.save
	end

	def croic
		oe = self.get_line("Owners' Earnings")
		invested_capital_lines = Array.new
		invested_capital_lines = ["Total Equity", "Total Liabilities"]
		ic = self.line_items.new(:yr0=>0,:yr1=>0,:yr2=>0,:yr3=>0,:yr4=>0, :yr5=>0,:yr6=>0,:yr7=>0,:yr8=>0,:yr9=>0)
		ic.save
		ic = self.sum(invested_capital_lines)
		ic.update_attribute(:name, "CROIC")
		current_liabs = self.get_line("Total Current Liabilities")
		cl = current_liabs.year_values
		current_assets = self.get_line("Total Current Assets")
		ca = current_assets.year_values
		self.subtract!(ic.name,current_liabs.name)
		excess_cash = self.line_items.new(:yr0=>0,:yr1=>0,:yr2=>0,:yr3=>0,:yr4=>0, :yr5=>0,:yr6=>0,:yr7=>0,:yr8=>0,:yr9=>0)
		excess_cash.update_attribute(:name, "Excess Cash")
		a = excess_cash.year_array
		i=0
		while i<a.length
			if cl[i]>ca[i]
				excess_cash.update_attribute(a[i], cl[i] - ca[i])
			end
			i=i+1
		end
		
		self.subtract!(ic.name, excess_cash.name)
		ic.divide!(oe.name)
		ic.multiply!(100)
	end

	def estimate
		symbol = self.symbol
		url = "http://financials.morningstar.com/valuation/earnings-estimates.html?t=#{symbol}&region=USA&culture=en-us"
		doc = Nokogiri::HTML(open(url))
		text = doc.css("tr:nth-child(11) td:nth-child(2)").first.text
		return number = text.to_f
	end
end
