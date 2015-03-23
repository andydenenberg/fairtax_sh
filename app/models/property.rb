class Property < ActiveRecord::Base
  attr_accessible :area, :assessed_value, :block, :category, :city, :class_code, :country, :gmaps, :latitude, :longitude, :neighborhood, :parcel, :pin, :street, :subdivision, :unit, :zip

  has_one :detail
  has_one :owner
  validates_uniqueness_of :pin
  
  acts_as_gmappable
  def gmaps4rails_address
  #describe how to retrieve the address from your model, if you use directly a db column, you can dry your code, see wiki
    "#{self.street}, #{self.city}, #{self.country}" 
  end

  def gmaps4rails_infowindow
    
    "<div class='popover-inner'><h3 class='popover-title'><a href='/properties/#{self.id}'>#{self.street}</a></h3><div class='popover-content'><p>PIN: #{self.pin}</p></div></div></div>"
    
#        "<h3 class='popover-title'>#{self.pin}</h3> <br> <a href='/properties/#{self.id}'>#{self.street}</a><br> #{self.latitude} <br> #{self.longitude} <br><br>"
  end

  def self.my_block(id,sort)
      begin
        myprop = Property.find(id)
#        sort = 'details.age DESC'
        @area = myprop.area
        @subdivision = myprop.subdivision
        @block = myprop.block
#        props = Property.find(:all, :conditions => ["area = :area AND subdivision = :subdivision AND block = :block", {:area => @area, :subdivision => @subdivision, :block => @block}])
        props = Property.where(:area => @area, :subdivision => @subdivision, :block => @block).includes(:detail).order(sort)
        return props
      rescue
        return nil
      end
  end

  def self.block_counts(town)
    blocks = Hash.new
    area_sub_block = [ ]
    blocks_arr = [ ]
    residentials = Property.where(:city => town, :category => 2)
    residentials.each do |prop|
      # 05-21-321-050-0000
      block = prop.pin[0..8]
      if !area_sub_block.include?(block)
        area_sub_block.push block
        blocks[block] = 1
      else
        blocks[block] += 1
      end
    end
    area_sub_block.each_with_index do |prop, i|
      property = residentials.where(:area => prop[0..1], :subdivision => prop[3..4], :block => prop[6..8]).order('assessed_value DESC')
      ave_assessed = property.average('assessed_value')
      max_prop = property[0]
      blocks_arr.push [ prop, blocks[prop], ave_assessed, max_prop.assessed_value, max_prop['street'], max_prop['id'] ]
    end
    blocks_arr.sort_by! { |a| -a[2] }
    
    # calculate stats  
    average = residentials.average('assessed_value').to_i
    count = residentials.count
    break_num = ( count / 5 ).to_i
    sort = residentials.order('assessed_value')  

    break_1_count = sort[0..break_num-1].count
    break_1_value = sort[break_num]['assessed_value']
    
    break_2_count = sort[break_num..2*break_num-1].count
    break_2_value = sort[2*break_num-1]['assessed_value']

    break_3_count = sort[2*break_num..3*break_num-1].count
    break_3_value = sort[3*break_num-1]['assessed_value']
    
    break_4_count = sort[3*break_num..4*break_num-1].count
    break_4_value = sort[4*break_num-1]['assessed_value']
    
    break_4 = residentials.order('assessed_value')[4*break_num]['assessed_value']
    stats = [ average, count, break_1_value, break_2_value, break_3_value, break_4_value, break_1_count, break_2_count, break_3_count, break_4_count ]
    return blocks_arr , stats   
  end
  

  def self.town_counts # returns a hash with all cities and the count of properties
    counts = Hash.new
    counts = Property.count(:all, :group => 'city', :order => 'city asc') 
    return counts   
  end

  def self.class_codes(town) # returns a hash of class codes and their count for a city
    cc = Hash.new
    cc = Property.count(:all, :conditions => ["city = ?", town], :group => 'class_code') 
    return cc   
  end
  
  def self.class_code_values(town, class_code_list) # returns a hash of count and total value for each class code
    ccv = Hash.new
    class_code_list.each do |cc, count|
        total_value = Property.sum(:assessed_value, :conditions => ["city = ? and class_code = ?", town, cc])
        ccv[cc] = [ count, total_value ]
    end  
    return ccv
  end

  def self.outside_geo(upper,lower,right,left)
    self.where('latitude > ? or latitude < ? or longitude > ? or longitude < ?', upper, lower, right, left)    
  end

  def self.town_values(towns)
    tv = Hash.new
    tv1 = Hash.new
    total_value = Property.sum(:assessed_value)
    towns.each do |t|
      town_value = Property.where(:city => t[0]).sum(:assessed_value)
      t_v = t[0] + ' - ' + town_value.to_s
      tv[t_v] = town_value
    end
    tv1 = tv.sort_by { |name, value| -value }
    tv = tv1.first(10)
    sum = 0
    tv.each do |t|
      sum += t[1].to_i
    end
    remainder = total_value.to_i - sum
    tv.push ['Reminder' , remainder]    
  return tv      
  end
  
    def self.missing_geo_code(towns) # towns is a hash with city( name and prop_count)
      missing = Hash.new
      total_props = 0
      total_missing = 0      
      total_value = Property.sum(:assessed_value)
      towns.each do |t|
      miss_count = Property.where(:latitude => nil, :city => t[0] ).count
      town_value = Property.where(:city => t[0]).sum(:assessed_value)
      percentage = town_value.to_f / total_value.to_f
      total = [ t[1] , miss_count , town_value, percentage ]
       missing[t[0]] = total
       total_props += t[1]
       total_missing += miss_count
      end       
      total = [ total_props, total_missing, total_value, 1 ]
      missing["Total"] = total
      return missing 
    end

    def self.total_town_value # returns a hash of total value for each city
      total_value = Hash.new
      total_value = Property.sum(:assessed_value, :group => 'city')
      return total_value
    end

    def self.comp_analysis_calc(props, primary)
      
      list = self.find(props)
      cas = Hash.new
      cas['multiplier'] = 3092160 / 62041.51   # check this with multiple properties agains't the county site
      
      cas['number_comps'] = list.length
#      cas['primary_pin'] = primary.pin
#      cas['street_city'] = primary.street + ', ' + primary.city
      
#      cas['current_building'] = primary.detail['current_building']
#      cas['current_building'] = 10 * primary.detail['current_building'] / cas['multiplier']
#      cas['my_building_ratio'] = primary.detail['building_value_ratio'].to_f

building_list = list.collect { |prop| prop.detail.building_size != nil ? prop.id : nil }
              
      cas['average_building'] = Detail.where(:property_id => building_list).average('details.current_building').to_f 
      cas['average_building_ratio'] = Detail.where(:property_id => building_list).average('details.building_value_ratio').to_f 
      cas['building_ratio_diff_percentage'] = ( 100 * (primary.detail.building_value_ratio - cas['average_building_ratio']) / cas['average_building_ratio'] )
      cas['annual_penalty_building'] = (cas['building_ratio_diff_percentage'].to_f * primary.detail.current_building ) / 100
        
#      cas['current_land'] = primary.detail['current_land']
#      cas['current_land'] = 10 * primary.detail['current_land'] / cas['multiplier']
#      cas['my_land_ratio'] = primary.detail['land_value_ratio'].to_f
      cas['average_land'] = Detail.where(:property_id => list).average('details.current_land').to_f 
      cas['average_land_ratio'] = Detail.where(:property_id => list).average('details.land_value_ratio').to_f 
      cas['land_ratio_diff_percentage'] = ( 100 * (primary.detail.land_value_ratio - cas['average_land_ratio']) / cas['average_land_ratio'] )      
      cas['annual_penalty_land'] = (cas['land_ratio_diff_percentage'].to_f * primary.detail.current_land ) / 100
      
      cas['current_year'] = primary.detail['current_year']
      cas['current_value'] = primary['assessed_value'] * 10
      cas['current_tax_dollars'] = cas['current_value'] / cas['multiplier']
      cas['current_land'] = 10 * primary.detail['current_land'] / cas['multiplier']
      return cas
    end
    
    
end
