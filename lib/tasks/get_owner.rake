namespace :import do
  task :get_owner => :environment do
 
      require "net/http"
      require "uri"
      require 'rubygems'
      require 'mechanize'
      require 'json'
      require 'nokogiri'
      
      puts 'started'

      escaped_query = 'hill rd'
      props = Property.where("street like :eq and city ='Winnetka'", {:eq => "%" + escaped_query + "%"})
#      props = Property.where(:street => '626 Hill Rd')

count = 1

    props.each do |prop|
      
      sleep 5
      
      
      pin = prop.pin
      
      (1..4).each do |p|
        pin = pin.sub('-','')
      end
      
        @agent = Mechanize.new 
        url = 'http://www.cookcountypropertyinfo.com/Pages/Pin-Results.aspx?pin=' + pin
        page = @agent.get(url)
        payload = page.body
        doc = Nokogiri::HTML(page.body)
        
        details = {}
        [
            [:tax_year, '//span[@id="ctl00_PlaceHolderMain_ctl00_mailingTaxYear"]'],
            [:mailing_name, '//span[@id="ctl00_PlaceHolderMain_ctl00_propertyMailingName"]'],
            [:mailing_address, '//span[@id="ctl00_PlaceHolderMain_ctl00_propertyMailingAddress"]'],
            [:mailing_city_state_zip, '//span[@id="ctl00_PlaceHolderMain_ctl00_propertyMailingCityStateZip"]'],
            ].collect do |name, xpath|
              details[name] = doc.xpath(xpath).text
            end
              
      print count.to_s + ' - ' + pin + ' - ' + details[:mailing_name] + ' - ' + details[:mailing_address] + ' - '
  
      count += 1
      
      url = 'http://chicago.blockshopper.com/property/' + pin + '/'
      page = @agent.get(url)
      payload = page.body
      doc = Nokogiri::HTML(page.body)

      price = doc.xpath('//table/tbody/tr[@class="first-row"]/td/strong/text()')
      buyer = doc.xpath('//table/tbody/tr[@class="first-row"]/td/a/text()')
      seller = doc.xpath('//table/tbody/tr[@class="second-row"]/td/a/text()')
      type = doc.xpath('//table/tbody/tr[@class="first-row"]/td/span/text()')
      date = doc.xpath('//table/tbody/tr[@class="first-row"]/td/text()')
  

      if price
        print price[0]
      end
        if date[4]
          # "\n12/04/1995\n"
          sale_date = date[4].to_s[2..10]
          print ' - ' + sale_date + ' - ' + type[0].to_s[1..6] + ' - ' + buyer[0].to_s + ',' + buyer[1].to_s
#          date.each_with_index do |d,i|
#            puts i.to_s + ' - ' + date[i].to_s
#          end
        end
                
      puts

end


end # task
end # namespace


