module MypropsHelper
  
  def comp_member(pin, id, list_num, primary_id)
    member = Myprop.find(:first, :conditions=> ["pin = :eq and list_num = :list_num and user_id = :current_user", {:eq => pin, :list_num => list_num, :current_user => current_user.id }]) 
    if member
        if member.status == 'primary'
          str = '<b>Primary</b>'
        else
          str = '<span class="label label-success">Yes</span><a class="btn btn-mini" href="/myprops/remove_prop?prop_id=' + id.to_s + '&list_num=' + list_num.to_s + '&id=' + primary_id.to_s + '">' + 'Remove</a>'
        end
    else
      str = '<span class="label">No</span><a class="btn btn-warning btn-mini" href="/myprops/add_prop' + '?prop_id=' + id.to_s + '&list_num=' + list_num.to_s + '&id=' + primary_id.to_s + '">' + 'Add</a>'
    end
    return str
  end
  
  
  def comp_status(pin, list_num)
    status = Myprop.where(:user_id => current_user, :pin => pin, :list_num => list_num)[0][:status]
    return status
  end
  
  def status_options(current_user)
    if Myprop.where(:user_id => current_user, :status => 'primary').length != 0
      status = [ 'comp', 'primary' ]
    else
      status = [ 'primary' ]
    end
    return status
  end
  
end
