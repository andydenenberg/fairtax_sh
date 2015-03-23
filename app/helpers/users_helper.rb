module UsersHelper
  
  def xslate_user(user_id)
    user = User.find(user_id).email
  end
  
end
