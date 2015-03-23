class Myprop < ActiveRecord::Base
  attr_accessible :city, :pin, :status, :street, :user_id, :list_num
    
  belongs_to :user
#  validates_uniqueness_of :pin
  
  def self.add_property(id, current_user_id, list_num)
        @myprop = self.new
        new_prop = Property.find(id)
        @myprop.list_num = list_num
        @myprop.pin = new_prop.pin
        @myprop.street = new_prop.street
        @myprop.city = new_prop.city
        @myprop.status = "comp"
        @myprop.user_id = current_user_id
        @myprop.save
  end

  def self.remove_property(id, current_user_id, list_num)
    prop = Property.find(id)
    pin = prop.pin
    @myprop = self.find(:all, :conditions => ["pin = ? and user_id =? and list_num = ?", pin, current_user_id, list_num])
    id = @myprop[0]['id']
    myprop = self.find(id)
    myprop.destroy
  end
  

  def self.my_comps(my_id, my_list_number)
      primary = Myprop.where(:status => 'primary', :list_num => my_list_number, :user_id => my_id)
      comps = self.where(:user_id => my_id, :list_num => my_list_number, :status => 'comp')
      pin_list = [ ]
      pin_list += comps.collect { |prop| [prop.pin] }
      comp_props = Property.where(:pin => pin_list)
      primary_prop = Property.where(:pin => primary[0][:pin])
      all_props = comp_props + primary_prop
      return [ primary_prop, comp_props, all_props ]    
  end
  
  def self.list_array(current_user)
   list_all = self.where(:user_id => current_user).order('list_num ASC').count(:all, :group => 'list_num') 
   list = [ 'Primary Property to New List' ]
   list += list_all.collect { |list_num, count| [ list_num ] }
    return list        
  end
  
  def self.most_favorable(list_num, current_user, 
      assessed_value_mult_hi, home_size_mult_hi, age_mult_hi,
      assessed_value_mult_low, home_size_mult_low, age_mult_low,       
      nhood_mult, class_mult, ext_constr_mult)

    @myproperty = self.find(:all, :conditions=> ["status = :eq AND user_id = :cu AND list_num = :list_num",
                                                {:eq => "primary", :cu => current_user, :list_num => list_num }])
    mypin = @myproperty[0]['pin']
    @myprop = Property.find(:all, :conditions=> ["pin = :eq", {:eq => mypin}])
    @myprop.each do |mp|
      @myprop_value = mp.assessed_value
      @myprop_size = mp.detail.building_size
      
      @myprop_age = mp.detail.age
      @myprop_neighborhood = mp.detail.neighborhood
      @myprop_class_code = mp.class_code
      @myprop_ext_const = mp.detail.ext_construction
      
      @mylat = mp.latitude
      @mylon = mp.longitude
      @mytown = mp.city
    end
        
    @hi_assessed_value = assessed_value_mult_hi # (@myprop_value.to_f * (1 + (assessed_value_mult.to_f/100).to_f))
    @low_assessed_value = assessed_value_mult_low # (@myprop_value.to_f * (1 - (assessed_value_mult.to_f/100).to_f))
    
    @hi_home_size = home_size_mult_hi # (@myprop_size.to_f * (1 + home_size_mult.to_f/100))
    @low_home_size = home_size_mult_low # (@myprop_size.to_f * (1 - home_size_mult.to_f/100))
    
#    age_mult == 'Unlimited' ? age_m = 10000 : age_m = age_mult
    
    @hi_age = age_mult_hi # (@myprop_age.to_f * (1 + age_m.to_f/100))
    @low_age = age_mult_low # (@myprop_age.to_f * (1 - age_m.to_f/100))

    nhood_clause = " AND details.neighborhood = '#{@myprop_neighborhood}'"
    classification_clause = " AND class_code = '#{@myprop_class_code}'"
    ext_constr_clause = " AND details.ext_construction = '#{@myprop_ext_const}'"
    
    options_clause = ''
        
    if nhood_mult == 'true'
       options_clause = options_clause + nhood_clause
    end
    if class_mult == 'true'
       options_clause = options_clause + classification_clause
    end
    if ext_constr_mult == 'true'      
       options_clause = options_clause + ext_constr_clause 
    end
    
    @properties = Property.find(:all, :include => :detail, :conditions => 
    ['assessed_value > :low_av and assessed_value < :hi_av and
      details.building_size < :hi_hs and details.building_size > :low_hs and
      details.age < :hi_age and details.age > :low_age and
      properties.city = :town' +  options_clause ,
       { :town => @mytown, :low_av => @low_assessed_value, :hi_av => @hi_assessed_value,
         :hi_hs => @hi_home_size, :low_hs => @low_home_size, :hi_age => @hi_age,
         :low_age => @low_age }], :order => 'details.building_value_ratio asc', :limit => 100 )  
#    @properties = @properties.reverse # sort high to low
    

    return @properties, @mylat, @mylon, @myprop, @multiplier, @myprop_size, @myprop_value, @myprop_age, @age_multiplier, @myprop_neighborhood
       
   end
  
end
