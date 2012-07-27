require 'rubygems'
require 'nokogiri'
require 'open-uri'

symbol = "CNTF"
url = "http://www.advfn.com/p.php?pid=financials&btn=annual_reports&mode=&symbol=NASDAQ%3A#{symbol}"
doc = Nokogiri::HTML(open(url))
#doc.css (".tr")
a=Array.new
i=0
title = doc.at_css("tr:nth-child(12) :nth-child(1)").text
doc.css("tr:nth-child(12) :nth-child(n+2)").each do |item|
	a[i]=item.text
	i+=1
end
puts(title)
	a.each do |value|
end