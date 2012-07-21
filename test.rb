require 'rubygems'
require 'nokogiri'
require 'open-uri'

url = "http://www.advfn.com/p.php?pid=financials&btn=annual_reports&mode=&symbol=NASDAQ%3ACNTF"
doc = Nokogiri::HTML(open(url))
#doc.css (".tr")
puts doc.css(".sb").text