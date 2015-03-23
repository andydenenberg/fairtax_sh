class ApplicationController < ActionController::Base
  protect_from_forgery
    
  before_filter :authenticate_user!
  
  def after_sign_in_path_for(resource)
    @myproperty = Myprop.find(:all, :conditions=> ["status = :eq AND user_id = :cu", {:eq => "primary", :cu => current_user.id}])
        if @myproperty.length > 0
          return myprops_path
        else
          return startup_myprops_path # myblock_home_index_path || startup_home_index_path
        end
  end
  
  
end
