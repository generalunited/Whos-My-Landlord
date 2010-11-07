require 'rubygems'
require 'mechanize'
require 'json'

def cmd
  __FILE__ == $0
end

def addr_to_bbl(houseno, street, boro)
  
  @agent = Mechanize.new

  @page = @agent.get('http://a810-bisweb.nyc.gov/bisweb/PropertyProfileOverviewServlet')

  bbl_form = @page.forms.first # => Mechanize::Form
  bbl_form['houseno'] = houseno
  bbl_form['street'] = street
  case boro.downcase
    when "manhattan"
      boro_option=1
    when "bronx"
      boro_option=2
    when "brooklyn"
      boro_option=3
    when "queens"
      boro_option=4
    when "staten island"
      boro_option=5
    else
      boro_option=1 #default is to assume it's boro of Manhattan
  end  
  bbl_form.field_with(:name => 'boro').options[boro_option].select

  @page = @agent.submit(bbl_form, bbl_form.buttons.first)
  tax_block = @page.search("//table[3]/tr[2]/td[9]/text()").to_s.sub(/:/,'').to_i
  tax_lot = @page.search("//table[3]/tr[3]/td[9]/text()").to_s.sub(/:/,'').to_i
  # 
  cmd ? (puts "Tax Block: " + tax_block.to_s):""
  cmd ? (puts "Tax Lot: " + tax_lot.to_s):""
    

  @page = @agent.get('http://api.blocksandlots.com/blankslate/json/data/743cd788-eb98-4fb6-af18-0811261ad168/records/search?apikey=cvq842zthjdvr25cq9p5s6db&Block='+tax_block.to_s+'&Lot='+tax_lot.to_s+'&rp=350&em=true&_=1289069608577')

  jdata = JSON.parse(@page.body)
  owner = ""

  jdata["application"][0]["entity"][0]["record"][0]["field"].each { |f|
    if f["fieldName"] == "Owner Name"
      owner = f["fieldValue"]
      cmd ? (puts "Owner: " + owner):""
    end
  }

  #TODO: find out how who is the actual current owner. Is it the last record?
  owners = []
  jdata["application"][0]["entity"][0]["record"].each do |record|
    record["field"].each do |f|
      if f["fieldName"] == "Owner Name"
        owners << f["fieldValue"]
      end
    end
  end
  cmd ? (puts "Possible Owners: #{owners}"):""
  more_about_owners = []
  owners.each do |owner|
    dos_page = @agent.get('http://dos.state.ny.us')
    dos_form = dos_page.forms[1]

    dos_form['p_entity_name'] = owner
    dos_page = @agent.submit(dos_form, dos_form.buttons.first)
    #  begin
    owner_link = dos_page.links.find do |l|
      if l.text[owner].nil?
        nil
      else
        l
      end
    end
    if owner_link.nil?
      cmd ? (puts "Owner #{owner} not found in DOS"):""
    else
      cmd ? (puts "Owner #{owner} was found in DOS"):""
      owner_page = owner_link.click
      o = owner_page.search("//table[@id='tblAddr']/tr[2]/td[1]/text()")
      more_about_owners<<o
      cmd ? (puts o;):"" 
    end
  end
  
  
  ret={
      :tax_block=>tax_block.to_s,
      :tax_lot=>tax_lot.to_s,
      :owner=>owner,
      :possible_owners=>owners,
      :more_about_owners=>more_about_owners
    }
  cmd ? (puts ret):""
  
end





if __FILE__ == $0
  addr_to_bbl('1412','NEW YORK AVENUE',"Brooklyn")
end