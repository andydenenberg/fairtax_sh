class Owner < ActiveRecord::Base

  attr_accessible :cc_name, :cc_tax_year, :cc_address, :cc_city_state_zip, :recent_sale_price, :recent_sale_date, :recent_seller, :recent_buyer, :property_id, :pin
  
  belongs_to :property 

  def self.owner_db(property_id,property_pin)
    owner = self.where(:property_id => property_id)
    if owner.length != 0
      owner_name = owner[0][:cc_name]
    else
      owner = get_owner(property_pin)
      owner_db = self.new
      owner_db.cc_name = owner[:mailing_name]
      owner_db.cc_address = owner[:mailing_address]
      owner_db.cc_city_state_zip = owner[:mailing_city_state_zip]
      owner_db.cc_tax_year = owner[:tax_year]
      owner_db.pin = property_pin
      owner_db.property_id = property_id
      owner_db.save
      owner_name = owner_db.cc_name
    end
    return owner_name    
  end


  def self.sales_db(property_id,property_pin)
    owner = self.where(:property_id => property_id)
    owner_id = owner[0]['id']
    sale = { }
      if owner[0]['recent_sale_price'] != nil
            sale['price'] = owner[0][:recent_sale_price]
            sale['seller'] = owner[0][:recent_seller]
            sale['buyer'] = owner[0][:recent_buyer]
            sale['date'] = owner[0][:recent_sale_date]
            sale['type'] = owner[0][:recent_sale_type]
      else
            sales = get_sales(property_pin)
            
            puts sales['no_sales_history']
                  
            if sales['no_sales_history'] == 'No sales history available'
              sales['price'] = 0
            end
      
            owner = Owner.find(owner_id)
            owner.recent_sale_price = sales['price']
            owner.recent_buyer = sales['buyer']
            owner.recent_seller = sales['seller']
            owner.recent_sale_type = sales['type']
            owner.recent_sale_date = sales['date']
            owner.save
            sale['price'] = owner.recent_sale_price
            sale['seller'] = owner.recent_seller
            sale['buyer'] = owner.recent_buyer
            sale['date'] = owner.recent_sale_date
            sale['type'] = owner.recent_sale_type
      end
    return sale
  end
 
 end 
  