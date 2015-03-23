class ClassCodesController < ApplicationController
  # GET /class_codes
  # GET /class_codes.json
  def index
    @class_codes = ClassCode.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @class_codes }
    end
  end

  # GET /class_codes/1
  # GET /class_codes/1.json
  def show
    @class_code = ClassCode.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @class_code }
    end
  end

  # GET /class_codes/new
  # GET /class_codes/new.json
  def new
    @class_code = ClassCode.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @class_code }
    end
  end

  # GET /class_codes/1/edit
  def edit
    @class_code = ClassCode.find(params[:id])
  end

  # POST /class_codes
  # POST /class_codes.json
  def create
    @class_code = ClassCode.new(params[:class_code])

    respond_to do |format|
      if @class_code.save
        format.html { redirect_to @class_code, notice: 'Class code was successfully created.' }
        format.json { render json: @class_code, status: :created, location: @class_code }
      else
        format.html { render action: "new" }
        format.json { render json: @class_code.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /class_codes/1
  # PUT /class_codes/1.json
  def update
    @class_code = ClassCode.find(params[:id])

    respond_to do |format|
      if @class_code.update_attributes(params[:class_code])
        format.html { redirect_to @class_code, notice: 'Class code was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @class_code.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /class_codes/1
  # DELETE /class_codes/1.json
  def destroy
    @class_code = ClassCode.find(params[:id])
    @class_code.destroy

    respond_to do |format|
      format.html { redirect_to class_codes_url }
      format.json { head :no_content }
    end
  end
end
