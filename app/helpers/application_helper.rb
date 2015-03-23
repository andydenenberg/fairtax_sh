module ApplicationHelper
  # Based on https://gist.github.com/1205828, in turn based on https://gist.github.com/1182136
  # Required to make Twitter’s Bootstrap CSS framework work with Will_paginate
  
  def block_comp_menu(primary_id, list_num)    
    block = ''
    comp = ''
    anal = ''
    if session[:block_comp] == 'comp'
      comp = ' active'
    elsif session[:block_comp] == 'block'
      block = ' active'
    elsif session[:block_comp] == 'analysis'
      anal = ' active'
    end
  
    if session[:sub_menu] == 'analysis'
      an = link_to 'Analysis', comp_analysis_summary_properties_path(:id => @primary_id,:list_num => @list_num), :class => 'btn' + anal
      bl = link_to "Block", my_block_analysis_properties_path(:id => primary_id, :list_num => list_num), :class => 'btn' + block
      cm = link_to "Comp", comp_analysis_building_rate_properties_path(:id => primary_id, :list_num => list_num), :class => 'btn' + comp
    elsif session[:sub_menu] == 'summary'
      an = link_to 'Analysis', comp_analysis_summary_properties_path(:id => @primary_id,:list_num => @list_num), :class => 'btn' + anal
      bl = link_to "Block", comp_block_summary_properties_path(:id => primary_id, :list_num => list_num), :class => 'btn' + block
      cm = link_to "Comp", comp_summary_properties_path(:id => primary_id, :list_num => list_num), :class => 'btn' + comp
    elsif session[:sub_menu] == 'map'
      an = link_to 'Analysis', comp_analysis_summary_properties_path(:id => @primary_id,:list_num => @list_num), :class => 'btn' + anal
      bl = link_to "Block", comp_block_map_properties_path(:id => primary_id, :list_num => list_num), :class => 'btn' + block
      cm = link_to "Comp", comp_map_properties_path(:id => primary_id, :list_num => list_num), :class => 'btn' + comp
    elsif session[:sub_menu] == 'taxes'
      an = link_to 'Analysis', comp_analysis_summary_properties_path(:id => @primary_id,:list_num => @list_num), :class => 'btn' + anal
      bl = link_to "Block", my_block_analysis_properties_path(:id => primary_id, :list_num => list_num), :class => 'btn' + block
      cm = link_to "Comp", comp_analysis_building_rate_properties_path(:id => primary_id, :list_num => list_num), :class => 'btn' + comp
    elsif session[:sub_menu] == 'favorable'
      an = link_to 'Analysis', comp_analysis_summary_properties_path(:id => @primary_id,:list_num => @list_num), :class => 'btn' + anal
      bl = link_to "Block", my_block_analysis_properties_path(:id => primary_id, :list_num => list_num), :class => 'btn' + block
      cm = link_to "Comp", comp_analysis_building_rate_properties_path(:id => primary_id, :list_num => list_num), :class => 'btn' + comp
    end	
    menu = '<p>' + an + '</p>' + '<p>' + bl + cm + '<p>'    
    return menu	
  end

  def sub_menu(primary_id, list_num)
    summary = ''
    map = ''
    taxes = ''
    if session[:sub_menu] == 'summary'
      summary = ' active'
    elsif session[:sub_menu] == 'map'
      map = ' active'
    elsif session[:sub_menu] == 'taxes'
      taxes = ' active'
    elsif session[:sub_menu] == 'favorable'
      taxes = ''
    end
      
    if session[:block_comp] == 'block'      
# in block
    su = link_to 'Summary', comp_block_summary_properties_path(:id => primary_id, :list_num => list_num), :class => 'btn' + summary 
    ma = link_to 'Map', comp_block_map_properties_path(:id => primary_id, :list_num => list_num), :class => 'btn' + map
    ta = link_to 'Taxes', my_block_analysis_properties_path(:id => primary_id, :list_num => list_num), :class => 'btn' + taxes
    sm = su + ma + ta
		elsif session[:block_comp] == 'comp'	
# in comp
    su = link_to 'Summary', comp_summary_properties_path(:id => primary_id, :list_num => list_num), :class => 'btn' + summary 
    ma = link_to 'Map', comp_map_properties_path(:id => primary_id, :list_num => list_num), :class => 'btn' + map
    ta = link_to 'Taxes', comp_analysis_building_rate_properties_path(:id => primary_id, :list_num => list_num), :class => 'btn' + taxes
    sm = su + ma + ta
   else
     sm = ''
    end
    return sm
  end


  def comp_menu(item)
    if session[:sub_menu] == item
      'active'
    else
      ''
    end
  end

  def top_menu(state,path)
    if session[:top_menu] == state
      return link_to state, path, :class => 'active' # highlight
    else
      return link_to state, path # normal
    end
  end
  
  def list_options
    list = Myprop.list_array(current_user)
    return list
  end
  
  def show_mine(prop_id)
       prop = Myprop.find(prop_id)
       pri_pin = Myprop.where(:status => 'primary', :user_id => current_user.id )[0][:pin]
  		 if prop.pin == pri_pin
  			 status = '<span class="badge badge-success">Primary</span>'
			 else
  		   status = ''
  		 end
  	return status    
  end

   class BootstrapLinkRenderer < ::WillPaginate::ActionView::LinkRenderer
     protected

     def html_container(html)
       tag :div, tag(:ul, html), container_attributes
     end

     def page_number(page)
       tag :li, link(page, page, :rel => rel_value(page)), :class => ('active' if page == current_page)
     end

     def gap
       tag :li, link(super, '#'), :class => 'disabled'
     end

     def previous_or_next_page(page, text, classname)
       tag :li, link(text, page || '#'), :class => [classname[0..3], classname, ('disabled' unless page)].join(' ')
     end
   end

   def page_navigation_links(pages)
     will_paginate(pages, :class => 'pagination', :inner_window => 2, :outer_window => 0, :renderer => BootstrapLinkRenderer, :previous_label => '&larr;'.html_safe, :next_label => '&rarr;'.html_safe)
   end
   
end
