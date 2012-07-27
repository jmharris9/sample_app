require 'rubygems'
require 'nokogiri'
require 'open-uri'

class Stock < ActiveRecord::Base
	attr_accessible :symbol, :name 
	belongs_to :user
	has_many :line_items, dependent: :destroy
	scope :search, lambda { |val|  where("symbol LIKE ?", "%#{val}%") }

	def grab_data
		#get webpage => note: start_date = number - 6 for actual start date
		symbol = self.symbol
		url = "http://www.advfn.com/p.php?pid=financials&btn=s_ok&mode=annual_reports&symbol=#{symbol}&s_ok=OK&start_date=13"
		doc = Nokogiri::HTML(open(url))

		#set stock name
		name = doc.at_css("h1").text
		self.update_attribute(:name, name)

		b = Array.new
		b = ["12",
			"14",
			"15",
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
			"83",
			"84",
			"85",
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
			"145",
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
			"201",]
		b.each do |line|
			#set line name
			@line_item = self.line_items.new
			@line_item.save
			line_name = doc.at_css("tr:nth-child(#{line}) :nth-child(1)").text
			line_name=line_name.gsub!(/\b[a-z0-9-_]/i){|l| l.upcase}
			@line_item.update_attribute(:name, line_name)
			#set line values
			a = Array.new
			a = [:yr0, :yr1, :yr2, :yr3, :yr4] 
			i=0
			doc.css("tr:nth-child(#{line}) :nth-child(n+2)").each do |item|
				word=item.text
				word.delete!(",")
				number = word.to_f
				@line_item.update_attribute(a[i], number)
				i=i+1
			end
		end
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
end
