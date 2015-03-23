# in lib/tasks rake test:import_props

namespace :import do
  task :set_class_codes => :environment do
  
    category = { }
    category[0] = "Unknown"
    category[1] = "Vacant"
    category[2] = "Residential"
    category[3] = "Multi-family"
    category[4] = "Not-for-profit"
    category[5] = "Major Commercial"
    category[6] = "Industrial Incentive"
    category[7] = "Commercial Incentive"
    category[8] = "Major Industrial/Commercial Incentive"
    category[9] = "Major Multi-Family Incentive"
    

  properties = Property.all
  
# Property.transaction do
  properties.each do |prop|

    puts prop.category
    if prop.category == nil
        value = (prop.class_code.to_s[0...1]).to_i
        prop.category = value
        puts prop.id.to_s + ' - ' + prop.class_code + ' - ' + value.to_s
        begin
           prop.save!
        rescue ActiveRecord::RecordNotSaved => e
          puts prop.errors.full_messages
        end
    else
      puts prop.id.to_s + ' - ' + prop.street + ' - already filled'
    end
#  end
end
  

#  Quote.transaction do
#   my_collection.each do |q|
#     Quote.create({:phrase => q})
#   end
#  end

    
  end
end

