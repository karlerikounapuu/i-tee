class CouponsController < ApplicationController
  #restricted to admins 
  before_action :authorise_as_manager
  #redirect to index view when trying to see unexisting things
  before_action :manager_tab
  
  # GET /coupons
  # GET /coupons.xml
  def index
    @own_coupons = Coupon.where(user_id: current_user).paginate(:page => params[:page], :per_page => 30)
    @coupons = Coupon.all.paginate(:page => params[:page], :per_page => 30)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @coupons }
    end
  end

  # GET /coupons/1
  # GET /coupons/1.xml
  def show
    Time.zone = 'Europe/Tallinn'
    @coupon = Coupon.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @coupon }
    end
  end

  # GET /coupons/new
  # GET /coupons/new.xml
  def new
    Time.zone = 'Europe/Tallinn'
    @coupon = Coupon.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @vmt }
    end
  end

  # GET /coupons/1/edit
  def edit
    Time.zone = 'Europe/Tallinn'
    @coupon = Coupon.find(params[:id])
  end

  # POST /coupons
  # POST /coupons.xml
  def create
    Time.zone = 'Europe/Tallinn'
    @coupon = Coupon.new(coupon_params)
    @coupon.user_id = current_user.id #author of coupon
    @coupon.lab_id = params[:coupon][:lab_id]

    respond_to do |format|
      if @coupon.save
        format.html { redirect_to(coupons_path, :notice => 'Coupon was successfully created.') }
        format.xml  { render :xml => @coupon, :status => :created, :location => @coupon }
      else
        format.html { render :action => 'new' }
        format.xml  { render :xml => @coupon.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /coupons/1
  # PUT /coupons/1.xml
  def update
    Time.zone = 'Europe/Tallinn'
    @coupon = Coupon.find(params[:id])
    @coupon.lab_id = params[:coupon][:lab_id]
    respond_to do |format|
      if @coupon.update_attributes(coupon_params)
        format.html { redirect_to(@coupon, :notice => 'Coupon was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => 'edit' }
        format.xml  { render :xml => @coupon.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /coupons/1
  # DELETE /coupons/1.xml
  def destroy
    @coupon = Coupon.find(params[:id])
    @coupon.destroy

    respond_to do |format|
      format.html { redirect_to(coupons_url) }
      format.xml  { head :ok }
    end
  end
private
def coupon_params
  params.require(:coupon).permit(:name, :redeemcode, :retention, :lab_id, :valid_from, :valid_through)	
end
end