class Detail < ActiveRecord::Base
  attr_accessible :age, :apartments, :attic, :basement, :building_size, :building_value_ratio, :central_air, :certified, :city, :classification, :current_building, :current_land, :current_value, :current_year, :description, :ext_construction, :fireplace, :full_bath, :garage, :half_bath, :land_size, :land_value_ratio, :neighborhood, :pin, :prior_building, :prior_land, :prior_value, :prior_year, :property_id, :res_type, :tax_code, :township, :use

  belongs_to :property 
  validates_uniqueness_of :pin

end
