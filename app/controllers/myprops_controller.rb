class MypropsController < ApplicationController
  # GET /myprops
  # GET /myprops.json

  skip_before_filter :authenticate_user!, :only => [ :startup ]


  def startup
    if current_user && (Myprop.where(:user_id => current_user.id, :list_num => 1).count > 0 )
      puts Myprop.where(:user_id => current_user.id, :list_num => 1).count
      redirect_to myprops_path
    else
      session[:top_menu] = 'startup'
      @property = Property.new   
    end   
  end
  
  def add_all_props
    list_num = params[:list_num]
      params[:prop_list].each do |prop|
        new_prop = Myprop.add_property(prop,current_user.id,list_num)
      end
    #    redirect_to mycomps_home_index_path
        redirect_to start_most_favorable_properties_path(:id => params[:id],:list_num => list_num )
  end

  def add_prop
    list_num = params[:list_num]
        new_prop = Myprop.add_property(params[:prop_id],current_user.id,list_num)
    #    redirect_to mycomps_home_index_path
        redirect_to most_favorable_properties_path(:id => params[:id],:list_num => list_num )
  end
  
  def remove_all_props
    comps = Myprop.where(:user_id => current_user.id, :list_num => params[:list_num])
      comps.each do |prop|        
        myprop = Myprop.find(prop.id)
        myprop.destroy
      end
    #    redirect_to mycomps_home_index_path
        redirect_to myprops_path(:id => params[:id],:list_num => params[:list_num] ), alert: "Comp List has been Deleted"
  end

  def remove_prop
    list_num = params[:list_num]
        remove_prop = Myprop.remove_property(params[:prop_id],current_user.id,list_num)
    #    redirect_to mycomps_home_index_path
        redirect_to most_favorable_properties_path(:id => params[:id],:list_num => list_num )
  end

  def add_to_my_list   
    
    @myprop = Myprop.new(params[:myprop])
    @status = params[:myprop][:status]   
    @prop = Property.where(:pin => @myprop.pin)
    @json = @prop.to_gmaps4rails     
  end

  def details

    @lists = Myprop.list_array(current_user)
    @lists.shift

    @list_num = params[:list_num]  
    @primary_id = Property.find(params[:id])  
    @mycomps = Myprop.where(:user_id => current_user.id, :list_num => params[:list_num])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @myprops }
    end
  end

  def list_all
    @all = Myprop.order('user_id ASC').order('list_num ASC')
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @myprops }
    end
  end

  def index
    session[:top_menu] = 'Analysis'
    @lists = Myprop.list_array(current_user)
    @lists.shift
    
    @groups = [ ]
    my_id = current_user.id # set in application.html  
    lists = Myprop.where(:user_id => my_id).count(:all, :group => 'list_num') 
        if lists.count == 1
          @last_map = true  # if only one map need to set true for gmaps
        else
          @last_map = false
        end
    lists.each do |list, count|
      prop_list = Myprop.my_comps(my_id,list)
      # http://mabp.kiev.ua/2010/01/12/google-map-markers/
            @json = prop_list[2].to_gmaps4rails do |prop, marker|
              if prop.pin != prop_list[0][0][:pin]
              marker.picture({
                  :picture => "http://labs.google.com/ridefinder/images/mm_20_green.png",
                  :width   => 12,
                  :height  => 20
                 })
              end
            end
            
        b_ave = Detail.where(:property_id => prop_list[1]).average('details.current_building').to_i
        br_ave = Detail.where(:property_id => prop_list[1]).average('details.building_value_ratio') 
        age_ave = Detail.where(:property_id => prop_list[1]).average('details.age')
            
        @comp_list_count = prop_list[1].count  
        @groups.push [ prop_list[0], prop_list[1], @json, list, b_ave, br_ave , age_ave, count ]
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @myprops }
    end
  end

  # GET /myprops/1
  # GET /myprops/1.json
  def show
    @myprop = Myprop.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @myprop }
    end
  end

  # GET /myprops/new
  # GET /myprops/new.json
  def new
    @myprop = Myprop.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @myprop }
    end
  end
  
  # GET /myprops/1/edit
  def edit
    @myprop = Myprop.find(params[:id])
  end

  # POST /myprops
  # POST /myprops.json
  def create
    @myprop = Myprop.new(params[:myprop])
    primary = Property.find(:all, :conditions => { :pin => @myprop[:pin]})
    @primary_id = primary[0]

    list = params[:myprop][:list_num]

    if list == 'Primary Property to New List'
      @myprop.status = 'primary'
      list = Myprop.list_array(current_user.id).last
        if list == 'Primary Property to New List' # if db results in null will be reset in .list_array
          list = 1
        else
          list = list[0] + 1
        end
      @myprop.list_num = list

    else
      @myprop.status = 'comp'
      primary_pin = Myprop.where(:user_id => current_user.id, :list_num => list, :status => 'primary' )[0].pin
      @primary_id = Property.where(:pin => primary_pin)[0]
      
    end
    @list_num = list
    
    respond_to do |format|
      if @myprop.save
        
#        format.html { redirect_to @myprop, notice: 'Myprop was successfully created.' }
        format.html { redirect_to comp_analysis_summary_properties_path(:id => @primary_id,:list_num => @list_num), notice: "Successfully added to Comp List " + list.to_s }
        format.json { render json: @myprop, status: :created, location: @myprop }
      else
#        format.html { render action: "new" }
        format.html { redirect_to start_search_properties_path, alert: "Property is already in list" }
        format.json { render json: @myprop.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /myprops/1
  # PUT /myprops/1.json
  def update
    @myprop = Myprop.find(params[:id])

    respond_to do |format|
      if @myprop.update_attributes(params[:myprop])
        format.html { redirect_to @myprop, notice: 'Myprop was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @myprop.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /myprops/1
  # DELETE /myprops/1.json
  def destroy
    @myprop = Myprop.find(params[:id])
    @myprop.destroy

    respond_to do |format|
      format.html { redirect_to myprops_url }
      format.json { head :no_content }
    end
  end
end
