class LabsController < ApplicationController
  layout 'main'
  before_filter :authorise_as_admin, :except => [:courses, :running_lab, :end_lab]

  # GET /labs
  # GET /labs.xml
  def index
    @labs = Lab.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @labs }
    end
  end

  # GET /labs/1
  # GET /labs/1.xml
  def show
    @lab = Lab.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @lab }
    end
  end

  # GET /labs/new
  # GET /labs/new.xml
  def new
    @lab = Lab.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @lab }
    end
  end

  # GET /labs/1/edit
  def edit
    @lab = Lab.find(params[:id])
  end

  # POST /labs
  # POST /labs.xml
  def create
    @lab = Lab.new(params[:lab])

    respond_to do |format|
      if @lab.save
        format.html { redirect_to(@lab, :notice => 'Lab was successfully created.') }
        format.xml  { render :xml => @lab, :status => :created, :location => @lab }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @lab.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /labs/1
  # PUT /labs/1.xml
  def update
    @lab = Lab.find(params[:id])

    respond_to do |format|
      if @lab.update_attributes(params[:lab])
        format.html { redirect_to(@lab, :notice => 'Lab was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @lab.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /labs/1
  # DELETE /labs/1.xml
  def destroy
    @lab = Lab.find(params[:id])
    @lab.destroy

    respond_to do |format|
      format.html { redirect_to(labs_url) }
      format.xml  { head :ok }
    end
  end

  def courses
    @labs=[] #only let the users pick from labs assigned to them
    @started=[]
    @complete=[]
    current_user.lab_users.each do |u|
      @labs<<u.lab        
      @started<<u.lab  if u.start!=nil && u.end==nil 
      @complete<<u.lab  if u.start!=nil && u.end!=nil 
    end 
      @labs=Lab.all if @admin #admins should see them all
      
      
    if params[:id]!=nil then
      @lab = Lab.find(params[:id])
    else
      @lab=@labs.first 
    end
     
    @allowed=false    # to avoid users from seeing labs, that arent for them
    if @labs.include?(@lab) then
      @allowed=true
    end
    
  end

  
  
  def running_lab
    @lab=Lab.find(params[:id])
    @lab_user = LabUser.find(:last, :conditions=>["lab_id=? and user_id=?", @lab.id, current_user.id])
    @note=""
    @vms=[]
    
    if @lab_user!=nil then #this user has this lab
    # generating vm info if needed
    @lab_user.lab.lab_vmts.each do |template|
      #is there a machine like that already?
      vm=Vm.find(:first, :conditions=>["lab_vmt_id=? and user_id=?", template.id, current_user.id ])
      if vm==nil && @lab_user.start==nil then
        #no there is not
        v=Vm.new
        v.name="#{template.name}-#{current_user.username}"
        #TODO mingi muu moodi nimi luua, see ei tule unikaalne
        v.lab_vmt_id=template.id
        v.user_id=current_user.id
        v.description="generated description"
        v.save
        @note="Machines successfully generated."
        @vms<<v
      else
        @vms<<vm
      end
    end #end of making vms based of templates
    if @lab_user.start==nil then
      @lab_user.start=Time.now
      @lab_user.save
    end
  else
    #the lab is not meant for this user, redirect
    redirect_to(error_401_path)
  end
  end
  
  def end_lab
    @lab_user=LabUser.find(params[:id])
    @note=""
    @lab=@lab_user.lab
    @lab_user.lab.lab_vmts.each do |template|
      #is there a machine like that 
      vm=Vm.find(:first, :conditions=>["lab_vmt_id=? and user_id=?", template.id, current_user.id ])
      if vm!=nil then
        #yes, delete it
        vm.destroy
        @note="Machines successfully deleted."
      end
    end #end of deleting vms for this lab
    if @note!="" then
      @lab_user.end=Time.now
      @lab_user.save
    end
    redirect_to(:back)
    #redirect_to(:action=>'running_lab', :id=>@lab.id)
  end
  
  
  def startLabJSON
    @msg = "ok"
    if user_signed_in? then
      Host.new.getEycalyptusInstance.startInstance("emi-E0DF1082", current_user.username )
    elsif @username then
      Host.new.getEycalyptusInstance.startInstance("emi-E0DF1082", @username )
    else
      @msg = "User not found!"
    end

    render :json => [@msg]
  end

end