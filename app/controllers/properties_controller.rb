class PropertiesController < ApplicationController
  # GET /properties
  # GET /properties.json

  #   @my comps = ['9 Indian Hill Rd', '13 Woodley Rd', '139 De Windt Rd','175 De Windt Rd', '181 De Windt Rd',    '305 White Oak Ln', '315 Woodley Rd','686 Hill Rd','626 Hill Rd']

    def valid_pin(val)
      # 05-21-321-050-0000
      if val.length == 18
        if val[2]+val[5]+val[9]+val[13] == '----'
          return true
        end
      end
          return false
    end
    
    def start_search
    session[:top_menu] = 'Properties'
    @property = Property.new
    session[:search_street] = '' # 'any'
    session[:search_city] = 'All' # 'Winnetka'
    session[:search_category] = 2 # 'Residential'
    session[:search_show_num] = 50
    @properties = Property.where(:city => session[:search_city], :category => session[:search_category] ).paginate :page => params[:page], :per_page => session[:search_show_num]
#    @properties = Property.paginate :page => params[:page], :per_page => 5
    
    end

    def search
      
      @list = Myprop.find(:all, :conditions => { :user_id => current_user })
      
      session[:search_street] = params[:property][:street]
      session[:search_city] = params[:property][:city]
      session[:search_category] = params[:property][:category]
      session[:search_show_num] = params[:zip]
      
      if params[:property][:street] != ''  
          if valid_pin(params[:property][:street])
            @properties = Property.where(:pin => params[:property][:street])
          else
            # need to Titleize to work on Heroku ( PG )
              if params[:property][:street] == 'any'
                search_street = ''
              else
                search_street = params[:property][:street]
              end
            escaped_query = search_street.gsub('%', '\%').gsub('_', '\_').titleize
            
            if params[:zip] == 'Unlimited'
              count = 10000
            else
              count = params[:zip]
            end
            @properties = Property.where("street like :eq", {:eq => "%" + escaped_query + "%"}).order("city DESC").paginate :page => params[:page], :per_page => 10 # session[:search_show_num]

            if params[:property][:city] != 'All'
              @properties = @properties.where(:city => params[:property][:city] ).order("assessed_value DESC")
            end
            if params[:property][:category] != 'All'
              @properties = @properties.where(:category => params[:property][:category] )
            end
          end   
                
          @property = Property.new
                
                   
            render 'search_result'
      else
      redirect_to start_search_properties_path
      end       
    end
 
    def city_block
      session[:top_menu] = 'Towns'
      
      city = params[:city]
      breakdown = Property.block_counts(city)
      @blocks = breakdown[0]
      @stats = breakdown[1]
      the_maxes = [ ]
      @blocks.each do |prop|
        the_maxes.push prop[5]
      end
      the_aves = [ ]
      @blocks.each do |prop|
        the_aves.push prop[2]
      end
      @legend = ["http://maps.google.com/intl/en_us/mapfiles/ms/micons/green.png", "http://maps.google.com/intl/en_us/mapfiles/ms/micons/blue.png","http://maps.google.com/intl/en_us/mapfiles/ms/micons/purple.png","http://maps.google.com/intl/en_us/mapfiles/ms/micons/yellow.png","http://maps.google.com/intl/en_us/mapfiles/ms/micons/red.png"]
      
#      @json = Property.find(the_maxes).to_gmaps4rails
      
      # http://mabp.kiev.ua/2010/01/12/google-map-markers/
            index = 0
            @json = Property.find(the_maxes).to_gmaps4rails do |prop, marker|
              value = the_aves[index]  # prop.assessed_value
              index += 1
              if value > @stats[5]
              marker.picture({
                :picture => "http://maps.google.com/intl/en_us/mapfiles/ms/micons/green.png",
                :width   => 32,
                :height  => 32,
                            })              
              elsif value > @stats[4] && value <= @stats[5]
              marker.picture({
                :picture => "http://maps.google.com/intl/en_us/mapfiles/ms/micons/blue.png",
                :width   => 32,
                :height  => 32
                             })
              elsif value > @stats[3] && value <= @stats[4]
              marker.picture({
                :picture => "http://maps.google.com/intl/en_us/mapfiles/ms/micons/purple.png",
                :width   => 32,
                :height  => 32
                           })
             elsif value > @stats[2] && value <= @stats[3]
             marker.picture({
               :picture => "http://maps.google.com/intl/en_us/mapfiles/ms/micons/yellow.png",
               :width   => 32,
               :height  => 32
                          })
            elsif value <= @stats[2]
            marker.picture({
              :picture => "http://maps.google.com/intl/en_us/mapfiles/ms/micons/red.png",
              :width   => 32,
              :height  => 32
                         })
            end
          end
            
    end
    
    def geo_stats
      session[:top_menu] = 'Towns'

      require 'town_poly_coord'
      city_town = params[:city]  
      @city = city_town
      @limits = town_boundaries(city_town)
      @total = Property.where(:city => city_town)
      @missing_geo = @total.where(:latitude => nil)
      @outside = @total.outside_geo(@limits[0], @limits[1], @limits[2], @limits[3])
      @properties = @outside.paginate(:page => params[:page], :per_page => 20)

      @residential = @total.where(:category => '2').order('assessed_value desc')

      @maximum = @residential.maximum(:assessed_value)
      @max_record = @residential.first

      @class_codes = Property.class_codes(city_town)

      @class_code_values = Property.class_code_values(city_town, @class_codes)

    end

  def comp_analysis_summary
    session[:top_menu] = 'Analysis'
    session[:block_comp] = 'analysis'
    session[:sub_menu] = 'analysis'
    prop_list = Myprop.my_comps(current_user,params[:list_num])
    @props = prop_list[1]  # @props.count is required for the show number of comps in list...
    @list_num = params[:list_num]
    @primary_id = params[:id]
    
    # find the temporary comps for first time user 
    prop = Property.find(@primary_id)
    session[:assessed_value_mult_hi] = ( prop.assessed_value * 1.20 ).to_i
    session[:home_size_mult_hi]  = ( prop.detail.building_size * 1.20 ).to_i
    session[:age_mult_hi] = ( prop.detail.age * 1.20 ).to_i 
    
    session[:nhood_mult] = true
    session[:class_mult] = true
    session[:ext_constr_mult] = true
    
    session[:assessed_value_mult_low] = ( prop.assessed_value * 0.80 ).to_i
    session[:home_size_mult_low] = ( prop.detail.building_size * 0.80 ).to_i
    session[:age_mult_low] = ( prop.detail.age * 0.80 ).to_i
    
    data = Myprop.most_favorable(@list_num,current_user,
      session[:assessed_value_mult_hi],     session[:home_size_mult_hi],     session[:age_mult_hi],
      session[:assessed_value_mult_low], session[:home_size_mult_low], session[:age_mult_low],
      session[:nhood_mult],session[:class_mult],session[:ext_constr_mult] )

    @t_comps  = data[0][0..10].collect { |prop| prop.id }
    @t_comps_cas = Property.comp_analysis_calc(@t_comps, data[3][0])  
    @t_comps_num = @t_comps.count      
      
    my_list = Myprop.where(:list_num => @list_num, :user_id => current_user.id, :status => 'comp' )
    my_list_array = my_list.collect { |prop| [ prop.pin ] }
    props_ids = Property.where(:pin => my_list_array)
    @comps = props_ids.collect { |prop| [ prop.id ] }
    
    primary = Myprop.where(:list_num => @list_num, :user_id => current_user.id, :status => 'primary')[0]
    primary = Property.where(:pin => primary.pin)[0]  
    @primary_id = primary
    @cas = Property.comp_analysis_calc(@comps, primary)    

    @lists = Myprop.list_array(current_user) # for drop-down list
    @lists.shift

    block = Property.my_block(@primary_id,'assessed_value DESC')
    block_ids = block.collect { |prop| [ prop.id ] }   
    
    @block_cas = Property.comp_analysis_calc(block_ids, primary)
                       
  end
  
    
    def start_most_favorable
      session[:top_menu] = 'Analysis' 
      session[:block_comp] = 'comp'   
      session[:sub_menu] = 'favorable'

      require 'find_distance'

      @primary_id = Property.find(params[:id])
      @list_num = params[:list_num]

      session[:assessed_value_mult_hi] = ( @primary_id.assessed_value * 1.20 ).to_i
      session[:home_size_mult_hi]  = ( @primary_id.detail.building_size * 1.20 ).to_i
      session[:age_mult_hi] = ( @primary_id.detail.age * 1.20 ).to_i 
      
      session[:nhood_mult] = true
      session[:class_mult] = true
      session[:ext_constr_mult] = true
      
      session[:assessed_value_mult_low] = ( @primary_id.assessed_value * 0.80 ).to_i
      session[:home_size_mult_low] = ( @primary_id.detail.building_size * 0.80 ).to_i
      session[:age_mult_low] = ( @primary_id.detail.age * 0.80 ).to_i
      
      data = Myprop.most_favorable(@list_num,current_user,
        session[:assessed_value_mult_hi],     session[:home_size_mult_hi],     session[:age_mult_hi],
        session[:assessed_value_mult_low], session[:home_size_mult_low], session[:age_mult_low],
        session[:nhood_mult],session[:class_mult],session[:ext_constr_mult] )
        
      @properties  = data[3] + data[0]

      @props = data[0]  # @props.count is required for the show number of comps in list...
      @lists = Myprop.list_array(current_user) # for drop-down list
      @lists.shift
            
      @graph = data[0]

      @mylat = data[1]
      @mylon = data[2]
      @myprop = data[3][0]
      @multiplier = data[4]
      @myprop_size = data[5]
      @myprop_value = data[6]
      @myprop_age = data[7]
      @age_multiplier = data[8]
      @myprop_neighborhood = data[9]

      num = 0
          @json = @properties.to_gmaps4rails do |prop, marker|
              if prop.pin != @myprop.pin
                num = num + 1
                marker.picture({
                     :picture => "/assets/block_mem" + num.to_s + ".png",
                     :width   => 20,
                     :height  => 34
                     })
              end
          end      
    end


        def graph_most_favorable

          @primary_id = Property.find(params[:id])
          @list_num = params[:list_num]

          require 'find_distance'


                session[:assessed_value_mult_hi] = params[:assessed_value_mult_hi]
                session[:home_size_mult_hi] = params[:home_size_mult_hi]
                session[:age_mult_hi] = params[:age_mult_hi]

                session[:nhood_mult] = params[:nhood_mult]
                session[:class_mult] = params[:class_mult]
                session[:ext_constr_mult] = params[:ext_constr_mult]

                session[:assessed_value_mult_low] = params[:assessed_value_mult_low]
                session[:home_size_mult_low] = params[:home_size_mult_low]
                session[:age_mult_low] = params[:age_mult_low]      

                data = Myprop.most_favorable(@list_num,current_user,
                session[:assessed_value_mult_hi],session[:home_size_mult_hi],session[:age_mult_hi],
                session[:assessed_value_mult_low], session[:home_size_mult_low], session[:age_mult_low],
                session[:nhood_mult],session[:class_mult],session[:ext_constr_mult])

                @properties  = data[3] + data[0]

                @props = data[0]  # @props.count is required for the show number of comps in list...
                @lists = Myprop.list_array(current_user) # for drop-down list
                @lists.shift

                @graph = data[0]

                @mylat = data[1]
                @mylon = data[2]
                @myprop = data[3][0]
                @multiplier = data[4]
                @myprop_size = data[5]
                @myprop_value = data[6]
                @myprop_age = data[7]
                @age_multiplier = data[8]
                @myprop_neighborhood = data[9]
                
                comps_list = data[0].collect { |prop| [prop.id] }
                average = Detail.where(:property_id => comps_list).average('details.building_value_ratio') 
                


            # tax_graph_data(list_of = nil, primary_prop, average,message)
            list_of = @graph
            primary_prop = @myprop
#            average = 30
            message = 'Primary'

                        count = 1
                        addr = [ ]
                        prop = [ ]
                        ave = [ ]
                        color = [ ]
                        mark = [ ]
                        
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
#                            prop.push [ street, list.detail.building_value_ratio, marker ]
#                            ave.push [ street, average, marker ]
                            addr.push street
                            prop.push list.detail.building_value_ratio
                            ave.push average
                            color.push c
                            mark.push marker
                          end
                        end
                        
                        graph_data = [ addr, prop, ave, color, mark ].to_json
                        
                        puts graph_data.to_s


              respond_to do |format|
                format.html { render json: graph_data }
                format.json { render json: graph_data }
              end

        end

    
    def search_most_favorable
      
      @primary_id = Property.find(params[:id])
      @list_num = params[:list_num]
      
      require 'find_distance'
      
      
            session[:assessed_value_mult_hi] = params[:assessed_value_mult_hi]
            session[:home_size_mult_hi] = params[:home_size_mult_hi]
            session[:age_mult_hi] = params[:age_mult_hi]

            session[:nhood_mult] = params[:nhood_mult]
            session[:class_mult] = params[:class_mult]
            session[:ext_constr_mult] = params[:ext_constr_mult]

            session[:assessed_value_mult_low] = params[:assessed_value_mult_low]
            session[:home_size_mult_low] = params[:home_size_mult_low]
            session[:age_mult_low] = params[:age_mult_low]      
            
            data = Myprop.most_favorable(@list_num,current_user,
            session[:assessed_value_mult_hi],session[:home_size_mult_hi],session[:age_mult_hi],
            session[:assessed_value_mult_low], session[:home_size_mult_low], session[:age_mult_low],
            session[:nhood_mult],session[:class_mult],session[:ext_constr_mult])

            @properties  = data[3] + data[0]
            
            @props = data[0]  # @props.count is required for the show number of comps in list...
            @lists = Myprop.list_array(current_user) # for drop-down list
            @lists.shift

            @graph = data[0]

            @mylat = data[1]
            @mylon = data[2]
            @myprop = data[3][0]
            @multiplier = data[4]
            @myprop_size = data[5]
            @myprop_value = data[6]
            @myprop_age = data[7]
            @age_multiplier = data[8]
            @myprop_neighborhood = data[9]
            
            num = 0
                @json = @properties.to_gmaps4rails do |prop, marker|
                    if prop.pin != @myprop.pin
                      num = num + 1
                      marker.picture({
                           :picture => "/assets/block_mem" + num.to_s + ".png",
                           :width   => 20,
                           :height  => 34
                           })
                     end
                end      
                                
          respond_to do |format|
            format.html { render :partial => 'most_favor', :layout => false }
            format.json { render json: @json }
            
#            format.json { render text: graph_data }
          end
                            
    end
    
    
    def most_favorable
      session[:top_menu] = 'Analysis' 
      session[:block_comp] = 'comp'   
      session[:sub_menu] = 'favorable'

      require 'find_distance'
      @list_num = params[:list_num]
      @primary_id = Property.find(params[:id])
            
#     session[:assessed_value_mult_hi] = params[:assessed_value_mult_hi]
#     session[:home_size_mult_hi] = params[:home_size_mult_hi]
#     session[:age_mult_hi] = params[:age_mult_hi]
#     
#     session[:nhood_mult] = params[:nhood_mult]
#     session[:class_mult] = params[:class_mult]
#     session[:ext_constr_mult] = params[:ext_constr_mult]
#     
#     session[:assessed_value_mult_low] = params[:assessed_value_mult_low]
#     session[:home_size_mult_low] = params[:home_size_mult_low]
#     session[:age_mult_low] = params[:age_mult_low]      
                 
#      data = Myprop.most_favorable(@list_num,current_user)
      data = Myprop.most_favorable(@list_num,current_user,
      session[:assessed_value_mult_hi],session[:home_size_mult_hi],session[:age_mult_hi],
      session[:assessed_value_mult_low], session[:home_size_mult_low], session[:age_mult_low],
      session[:nhood_mult],session[:class_mult],session[:ext_constr_mult])
 
      @properties  = data[3] + data[0]

      @props = data[0]  # @props.count is required for the show number of comps in list...
      @lists = Myprop.list_array(current_user) # for drop-down list
      @lists.shift
      
      
      @graph = data[0]

      @mylat = data[1]
      @mylon = data[2]
      @myprop = data[3][0]
      @multiplier = data[4]
      @myprop_size = data[5]
      @myprop_value = data[6]
      @myprop_age = data[7]
      @age_multiplier = data[8]
      @myprop_neighborhood = data[9]

                num = 0
                      @json = @properties.to_gmaps4rails do |prop, marker|
                        if prop.pin != @myprop.pin
                num = num + 1
                        marker.picture({
                                        :picture => "/assets/block_mem" + num.to_s + ".png",
                                        :width   => 20,
                                        :height  => 34
                                       })
                        end
                      end
    end
  
  
  def comp_analysis_building_rate
    session[:top_menu] = 'Analysis'
    session[:block_comp] = 'comp'
    session[:sub_menu] = 'taxes'
    
    
    @lists = Myprop.list_array(current_user)  # needed for drop-down menu
    @lists.shift
        
    @primary_id = Property.find(params[:id])
    
    @list_num = params[:list_num]
    list = Myprop.where(:list_num => @list_num, :user_id => current_user.id)
    pin_list = list.collect { |prop| [ prop.pin ]}
    comp_pin_list = list.collect { |prop| [ prop.pin != @primary_id.pin ? prop.pin : nil ]}
    comps = Property.where(:pin => comp_pin_list)
    comps_list = comps.collect { |prop| [prop.id] }
    
    props = Property.where(:pin => pin_list)
    list = props.collect { |prop| [prop.id] }
    
    @properties = Property.find(list,:include => :detail, :order => 'details.building_value_ratio desc') 
    @props = comps # @props.count is required for the show number of comps in list...
    
    
#    @graph = @properties     
#    @building = Property.find(list,:include => :detail, :order => 'details.building_value_ratio') 
    @br_average = Detail.where(:property_id => comps_list).average('details.current_building').to_i
    @average = Detail.where(:property_id => comps_list).average('details.building_value_ratio') 
    @land_average = Detail.where(:property_id => comps_list).average('details.land_value_ratio') 
    
    @properties.each do |prop|
      checkit = Owner.owner_db(prop.id,prop.pin) 
    end 
    
#    @max = Detail.where(:property_id => list).maximum('details.building_value_ratio') 
#    @min = Detail.where(:property_id => list).minimum('details.building_value_ratio')
           
  end

      def comp_summary
        session[:top_menu] = 'Analysis'
        session[:block_comp] = 'comp'
        session[:sub_menu] = 'summary'
        
        @primary_id = Property.find(params[:id])
        @list_num = params[:list_num]

        @lists = Myprop.list_array(current_user)
        @lists.shift
          if sort = params[:sort] 
            else sort = 'assessed_value DESC'
          end

          prop_list = Myprop.my_comps(current_user,@list_num)
          @props = prop_list[1]
          
        @props.each do |prop|
          checkit = Owner.owner_db(prop.id,prop.pin) 
        end 

      end 


 
    def comp_block_summary
      session[:top_menu] = 'Analysis'
      session[:block_comp] = 'block'
      session[:sub_menu] = 'summary'
            
      @lists = Myprop.list_array(current_user)
      @lists.shift
        if sort = params[:sort] 
          else sort = 'assessed_value DESC'
        end
      
      @props = Property.my_block(params[:id],sort)
#      @json = @props.to_gmaps4rails
      @primary_id = Property.find(params[:id])
      @list_num = params[:list_num]
      
      @props.each do |prop|
        checkit = Owner.owner_db(prop.id,prop.pin) 
      end 

    end 

      def comp_block_map
        session[:top_menu] = 'Analysis'
        session[:block_comp] = 'block'
        session[:sub_menu] = 'map'
        
        @lists = Myprop.list_array(current_user)
        @lists.shift
        
        @primary_id = Property.find(params[:id])
        @list_num = params[:list_num]

        @myprop = Property.find(params[:id])
        @props = Property.my_block(params[:id],'assessed_value DESC')
        
        if @props != nil

    # http://mabp.kiev.ua/2010/01/12/google-map-markers/
          num = 0
          @json = @props.to_gmaps4rails do |prop, marker|
            if prop.id.to_i != params[:id].to_i
             # marker.picture({ :picture => "http://labs.google.com/ridefinder/images/mm_20_green.png",
          num = num + 1
              marker.picture({ :picture => "/assets/block_mem" + num.to_s + ".png",
             #               :width   => 12, :height  => 20  })
                            :width   => 20, :height  => 34  })
            end
          end
        end
 
        temp = @props.collect { |prop| prop.id }
        temp.delete @myprop.id
        @props = Property.find(temp)
      
      end
      

        def comp_map
          session[:top_menu] = 'Analysis'
          session[:block_comp] = 'comp'
          session[:sub_menu] = 'map'
          
          @lists = Myprop.list_array(current_user)
          @lists.shift

          @list_num = params[:list_num]
          @primary_id = Property.find(params[:id])
          
      # Initialize session variables before entering the most_favorable section
      # this initialization should be moved if the link from myprops/index is changed
      
            prop = @primary_id
            session[:assessed_value_mult_hi] = ( prop.assessed_value * 1.20 ).to_i
            session[:home_size_mult_hi]  = ( prop.detail.building_size * 1.20 ).to_i
            session[:age_mult_hi] = ( prop.detail.age * 1.20 ).to_i 

            session[:nhood_mult] = true
            session[:class_mult] = true
            session[:ext_constr_mult] = true

            session[:assessed_value_mult_low] = ( prop.assessed_value * 0.80 ).to_i
            session[:home_size_mult_low] = ( prop.detail.building_size * 0.80 ).to_i
            session[:age_mult_low] = ( prop.detail.age * 0.80 ).to_i          
          
          num = 0
          prop_list = Myprop.my_comps(current_user,@list_num)
          @props = prop_list[1]

          # http://mabp.kiev.ua/2010/01/12/google-map-markers/
                @json = prop_list[2].to_gmaps4rails do |prop, marker|
                  if prop.pin != prop_list[0][0][:pin]
          num = num + 1
                  marker.picture({
#                    :picture => "http://labs.google.com/ridefinder/images/mm_20_green.png",
#                    :width   => 12,
#                    :height  => 20
                                  :picture => "/assets/block_mem" + num.to_s + ".png",
                                  :width   => 20,
                                  :height  => 34
                                 })
                  end
                end

        end
  

  def my_block_summary
    session[:top_menu] = 'Properties'
    @props = Property.my_block(params[:id],'assessed_value DESC')
#    @json = @props.to_gmaps4rails
    
#    require 'find_distance'
    @myprop = Property.find(params[:id])
#    @mylat = @myprop.latitude
#    @mylon = @myprop.longitude
    
    @props.each do |prop|
      checkit = Owner.owner_db(prop.id,prop.pin) 
    end 
    
    
#    ids = @props.collect { |prop| [ prop.id ] }
#    @cas = Property.comp_analysis_calc(ids, @myprop)     
    
#    @owner_info = [ ]
#    @props.each do |prop|
#      temp = get_owner(prop.pin) 
#      puts temp.inspect
#      @owner_info.push temp
#    end
                         
    
  end
  
  def my_block_analysis
    session[:top_menu] = 'Analysis'
    session[:block_comp] = 'block'
    session[:sub_menu] = 'taxes'
    
    @lists = Myprop.list_array(current_user)
    @lists.shift

    @primary_id = Property.find(params[:id])
    @list_num = params[:list_num]
    
    @props = Property.my_block(params[:id],params[:sort])
    @myprop = Property.find(params[:id])
    
    props = @props
    list = props.collect { |prop| [prop.id] }
    
    
    @properties = Property.find(list,:include => :detail, :order => 'details.building_value_ratio desc') 
    @graph = @properties

    @props.each do |prop|
      checkit = Owner.owner_db(prop.id,prop.pin) 
    end 

    rank = @properties.collect { |prop| prop.id.to_i }
    @rank = rank.index(params[:id].to_i) + 1
         
    @building = Property.find(list,:include => :detail, :order => 'details.building_value_ratio')

    
    building_list = @properties.collect { |prop| prop.detail.building_size != nil ? prop.id : nil }

    @average = Detail.where(:property_id => building_list).average('details.building_value_ratio') 
#    @max = Detail.where(:property_id => list).maximum('details.building_value_ratio') 
#    @min = Detail.where(:property_id => list).minimum('details.building_value_ratio')   

  end

  def my_block_analysis_summary
    session[:top_menu] = 'Properties'
    @props = Property.my_block(params[:id],'assessed_value DESC')
    @myprop = Property.find(params[:id])
    
    ids = @props.collect { |prop| [ prop.id ] }
    @cas = Property.comp_analysis_calc(ids, @myprop)                         
    @value = Property.where(:id => ids).order('assessed_value DESC')
    @average_value = @value.average('assessed_value')
    
  end


  def my_block_map
    session[:top_menu] = 'Properties'
#    @props = Property.my_block(params[:pin])
    @myprop = Property.find(params[:id])
    @props = Property.my_block(params[:id],'assessed_value DESC')
    if @props != nil

# http://mabp.kiev.ua/2010/01/12/google-map-markers/
      @json = @props.to_gmaps4rails do |prop, marker|
        if prop.id.to_i != params[:id].to_i
        marker.picture({
                        :picture => "http://labs.google.com/ridefinder/images/mm_20_green.png",
                        :width   => 12,
                        :height  => 20
                       })
        end
      end
    end
  end
  
  def edit_location
    
    @property = Property.find(params[:id] )
    @json = @property.to_gmaps4rails
    
    
  end
  
  
  
  def home
    session[:top_menu] = 'Towns'
        town_counts = Property.town_counts
        @missing =  Property.missing_geo_code(town_counts)
        @total_town_value = Property.total_town_value
        @total_value = Property.sum(:assessed_value)
        
        @data = Property.town_values(town_counts)
                 
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @properties }
    end       
  end
  
  def index
    session[:top_menu] = 'Properties'
    @properties = Property.paginate :page => params[:page], :per_page => 5
#    @properties = Property.where(:id => 78360).paginate :page => params[:page], :per_page => 5
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @properties }
    end
  end

  # GET /properties/1
  # GET /properties/1.json
  def show
    session[:top_menu] = 'Properties'
    @property = Property.find(params[:id], :include => :detail, :order => 'details.building_value_ratio desc')
    @owner_name = Owner.owner_db(params[:id],@property.pin)  
    
    @sale = Owner.sales_db(@property.id, @property.pin) # check and update the sales info
        
    @json = @property.to_gmaps4rails
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @property }
    end
  end

  # GET /properties/new
  # GET /properties/new.json
  def new
    @property = Property.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @property }
    end
  end

  # GET /properties/1/edit
  def edit
    @property = Property.find(params[:id])
  end

  # POST /properties
  # POST /properties.json
  def create
    @property = Property.new(params[:property])

    respond_to do |format|
      if @property.save
        format.html { redirect_to @property, notice: 'Property was successfully created.' }
        format.json { render json: @property, status: :created, location: @property }
      else
        format.html { render action: "new" }
        format.json { render json: @property.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /properties/1
  # PUT /properties/1.json
  def update
    @property = Property.find(params[:id])

    respond_to do |format|
      if @property.update_attributes(params[:property])
        format.html { redirect_to @property, notice: 'Property was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @property.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /properties/1
  # DELETE /properties/1.json
  def destroy
    @property = Property.find(params[:id])
    @property.destroy

    respond_to do |format|
      format.html { redirect_to properties_url }
      format.json { head :no_content }
    end
  end
end




  def get_owner(pin) 
      require "net/http"
      require "uri"
      require 'rubygems'
      require 'mechanize'
      require 'json'
      require 'nokogiri'
        stripped_pin = pin.tr('-','')
      
        @agent = Mechanize.new 
        url = 'http://www.cookcountypropertyinfo.com/Pages/Pin-Results.aspx?pin=' + stripped_pin
        page = @agent.get(url)
        payload = page.body
        doc = Nokogiri::HTML(page.body)
        owners = {}
        [
            [:tax_year, '//span[@id="ctl00_PlaceHolderMain_ctl00_mailingTaxYear"]'],
            [:mailing_name, '//span[@id="ctl00_PlaceHolderMain_ctl00_propertyMailingName"]'],
            [:mailing_address, '//span[@id="ctl00_PlaceHolderMain_ctl00_propertyMailingAddress"]'],
            [:mailing_city_state_zip, '//span[@id="ctl00_PlaceHolderMain_ctl00_propertyMailingCityStateZip"]'],
            ].collect do |name, xpath|
              owners[name] = doc.xpath(xpath).text
            end
                                              
      return owners
  end

  def get_sales(pin)
      require "net/http"
      require "uri"
      require 'rubygems'
      require 'mechanize'
      require 'json'
      require 'nokogiri'
      stripped_pin = pin.tr('-','')
    
      @agent = Mechanize.new 
          url = 'http://chicago.blockshopper.com/property/' + stripped_pin + '/'
          begin
          page = @agent.get(url)
          payload = page.body
          doc = Nokogiri::HTML(page.body)
          
          sales = { }
          sales['price'] = doc.xpath('//table/tbody/tr[@class="first-row"]/td/strong/text()')[0].to_s.tr('$','').tr(',','')
          sales['buyer'] = doc.xpath('//table/tbody/tr[@class="first-row"]/td/a/text()')[0].to_s
          sales['seller'] = doc.xpath('//table/tbody/tr[@class="second-row"]/td/a/text()')[0].to_s
          sales['type'] = doc.xpath('//table/tbody/tr[@class="first-row"]/td/span/text()')[0].to_s
          sales['date'] = doc.xpath('//table/tbody/tr[@class="first-row"]/td/text()')[4].to_s[2..10]
          sales['no_sales_history'] = doc.xpath('//table/tbody/tr/td[@class="tcenter"]/text()').to_s

        rescue
          sales = { }
        end

      return sales

    
  end
