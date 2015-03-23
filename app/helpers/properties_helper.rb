module PropertiesHelper

    def higher_lower(value)
      puts value
      if value > 0
        return "<font color='ff0000'>" + number_with_precision( value.abs, :precision => 2 ).to_s + ' %</font> higher'
      else value < 0
        return "<font color='006600'>" + number_with_precision( value.abs, :precision => 2 ).to_s + ' %</font> lower'
#      else
#        return "<font color='000000'>" + 'equal</font> to'      
     end    
    end
    
    def tax_graph_value(list_of = nil, primary_prop)
      prop = ''
      list_of.each_with_index do |list, i|

        if list.detail.building_size
        street = list.street[0..10]
            if primary_prop == list
              marker = 'Primary'
            else 
              marker = ''
            end        

          prop = prop + "['#{street}', #{list.assessed_value}, '' ],"
        end
      end
      return prop[0..-1]
    end

    def block_summary_graph(list_of = nil, primary_prop, average)
      value = '[ '
      bs = '[ '
      addr = '[ '
      list_of[0..9].each_with_index do |list, i|
        street = list.street[0..10]
          value = value + "#{list.assessed_value/1000} ,"
          bs = bs + "#{list.detail.building_size} ,"
          addr = addr + "'#{street}',"
      end
      value = value[0..-2] + ']'
      bs = bs[0..-2] + ']'
      addr = addr[0..-2] + ']'
      
      return value[0..-1], bs[0..-1], addr[0..-1]
    end

    def tax_graph_rate(list_of = nil, primary_prop, average,message)
      count = 1
      prop = ''
      ave = ''
      color = '[ '
      marker = ''
      list_of.each_with_index do |list, i|

        if list.detail.building_size
        street = list.street[0..10]
            if primary_prop == list
              if message != ''
              marker = message + '- Ranked #' + (i+1).to_s
              end
             # blue = "#4BB2C5"
             # brown = "#EAA228"
             # green = "#73C774"
              c = '#4BB2C5'
            else 
              marker = ''
              c = '#73C774'
            end        
          prop = prop + "['#{street}', #{list.detail.building_value_ratio}, '#{marker}'],"
          ave = ave + "['#{street}', #{average}, '#{marker}'],"
          color = color + "'#{c}' , "
        end
      end
      color = color + ' ]'
      return [ prop[0..-1], ave[0..-1], color[0..-1] ]
    end

    def bl_graph_rate(list_of = nil, primary_prop, building_average,land_average)
      building = ''
      building_ave = ''
      land = ''
      land_ave = ''
      list_of.each_with_index do |list, i|
        street = list.street[0..10]
          building = building + "['#{street}', #{list.detail.building_value_ratio} ],"
          building_ave = building_ave + "['#{street}', #{building_average} ],"
          land = land + "['#{street}', #{list.detail.land_value_ratio} ],"
          land_ave = land_ave + "['#{street}', #{land_average} ],"
      end
      return [ building[0..-1], building_ave[0..-1], land[0..-1], land_ave[0..-1] ]
    end


  def bubble_building(list_of = nil)
    # [x, y, radius, <label or object>]
    x = 0
    y = 0
    radius = 0
    street = 0
    prop = ''
    list_of.each_with_index do |list, i|
      
      if list.detail.building_size
       y =   list.detail.building_value_ratio
       x = i * 10
      radius = y  #  list.detail.building_size
      street = list.street[0..10]
        if y && radius
          prop = prop + "[#{x}, #{y}, #{radius}, '#{street}'],"
        end
      end
    end
    return prop[0..-1]
  end

  def ar(test)
    prop = ''
    test.each do |city|
      prop = prop + "['#{city[0]}', #{city[1]}],"
    end
    ret = prop[0..-2]
    return ret
  end

  def block_values(stats)
    prop = "['low', #{stats[2]} ], ['mid', #{stats[3]} ], ['high', #{stats[4]} ], ['highest', #{stats[5]} ]"
    return prop
  end

  def class_code_lu(code)
      ccode = ClassCode.where(:cc => code)
      return ccode[0]['description'] # [0...50]
  end
  
  def most_favor_range(value)
    resp = [ ]
    (0..20).each do |val|
      resp += [ ( ( value.to_f * val * 10 ) / 100 ).to_i ]
    end
    resp.reverse!
    return resp
  end
    

  def cities_for_select
    towns = Property.town_counts
    towns.delete('')
    @cities = [ 'All' ]
    @cities += towns.collect { |city, count| [city] }
    return @cities
  end
  
  def class_codes_for_select
    codes = ClassCode.all
    @codes = [ 'All' ]
    @codes += codes.collect { |code| [code.cc] }
    @codes.delete_at(1) # remove the blank
    return @codes
  end
  
  def categories_for_select
    category = [ ]
    category[0] = "All"
    category[1] = [ "Unknown" , 0 ]
    category[2] = [ "Vacant" , 1 ]
    category[3] = [ "Residential" , 2 ]
    category[4] = [ "Multi-family" , 3 ]
    category[5] = [ "Not-for-profit" , 4 ]
    category[6] = [ "Major Commercial" , 5 ]
    category[7] = [ "Industrial Incentive" , 6 ]
    category[8] = [ "Commercial Incentive" , 7 ]
    category[9] = [ "Major Industrial/Commercial Incentive" , 8 ]
    category[10] = [ "Major Multi-Family Incentive" , 9 ]
    return category
  end
  
  def categories_lu(cat)
    cat += 1
    c = categories_for_select[cat][0]
    return c    
  end

  def ave_value_legend(value,legend)
      if value > legend[5]
        picture = "http://labs.google.com/ridefinder/images/mm_20_green.png"
        
      elsif value > legend[4] && value <= legend[5]
        picture = "http://labs.google.com/ridefinder/images/mm_20_blue.png"
      elsif value > legend[3] && value <= legend[4]
        picture = "http://labs.google.com/ridefinder/images/mm_20_purple.png"
      elsif value > legend[2] && value <= legend[3]
        picture = "http://labs.google.com/ridefinder/images/mm_20_yellow.png"
      elsif value <= legend[2]
        picture = "http://labs.google.com/ridefinder/images/mm_20_red.png"
      end
    return picture    
  end

end

