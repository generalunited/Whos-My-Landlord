require 'rubygems'
require 'mechanize'
require 'json'

agent = Mechanize.new

page = agent.get('http://a810-bisweb.nyc.gov/bisweb/PropertyProfileOverviewServlet')

bbl_form = page.forms.first # => Mechanize::Form
bbl_form['houseno'] = '1412'
bbl_form['street'] = 'NEW YORK AVENUE'
bbl_form.field_with(:name => 'boro').options[3].select
# 1 Manhattan
# 2 Bronx
# 3 Brooklyn
# 4 Queens
# 5 Staten Island

page = agent.submit(bbl_form, bbl_form.buttons.first)
tax_block = page.search("//table[3]/tr[2]/td[9]/text()").to_s.sub(/:/,'').to_i
tax_lot = page.search("//table[3]/tr[3]/td[9]/text()").to_s.sub(/:/,'').to_i

puts "Tax Block: " + tax_block.to_s
puts "Tax Lot: " + tax_lot.to_s

page = agent.get('http://api.blocksandlots.com/blankslate/json/data/743cd788-eb98-4fb6-af18-0811261ad168/records/search?apikey=cvq842zthjdvr25cq9p5s6db&Block='+tax_block.to_s+'&Lot='+tax_lot.to_s+'&rp=350&em=true&_=1289069608577')

jdata = JSON.parse(page.body)

owner = ""

jdata["application"][0]["entity"][0]["record"][0]["field"].each { |f|
  if f["fieldName"] == "Owner Name"
    owner = f["fieldValue"]
    puts "Owner: " + owner
  end
}

dos_page = agent.get('http://dos.state.ny.us')
dos_form = dos_page.forms[1]

dos_form['p_entity_name'] = owner
dos_page = agent.submit(dos_form, dos_form.buttons.first)

owner_page = dos_page.link_with(:text => owner).click

puts owner_page.search("//table[@id='tblAddr']/tr[2]/td[1]/text()")




