class PosController < ApplicationController

  # disable protection on POST PUT?
  protect_from_forgery :only => [ :delete, :update]

  # GET /pos
  # GET /pos.xml
  def index
    @pos = Po.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @pos }
    end
  end

  # GET /pos/1
  # GET /pos/1.xml
  def show
    @po = Po.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @po }
    end
  end

  # GET /pos/new
  # GET /pos/new.xml
  def new
    @po = Po.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @po }
    end
  end

  # GET /pos/1/edit
  def edit
    @po = Po.find(params[:id])
  end


  #{"latitude"=>"55.589842", "accuracy"=>"1174.0", "altitude"=>"0.0", "time"=>"2011-03-14T21:22:43.
  #987Z", "bearing"=>"0.0", "speed"=>"0.0", "longitude"=>"12.943554", "charging"=>"1", "battlevel"=>"46", "provid
  #er"=>"network"}

  # POST /pos
  # POST /pos.xml
  def create
    puts 'create.xml ' + params.inspect

    @po = Po.new({:latitude => params[:latitude],
      :longitude => params[:longitude],
      :accuracy => params[:accuracy],
      :altitude => params[:altitude],
      :time => params[:time],
      :bearing => params[:bearing],
      :speed => params[:speed],
      :provider => params[:provider],
      :battlevel => params[:battlevel],
    })

    #@po=params
    #puts 'po ' + @po.inspect
    #$stdout.flush

    #@person.attributes.to_options!
    #Time.parse("2007-01-31 12:22:26")
    #DateTime.strptime("12/25/2007 01:00 AM EST", "%m/%d/%Y %I:%M %p %Z")
    #DateTime.strptime("12/25/2007 01:00 AM EST", "%m/%d/%Y %I:%M %p %Z").utc.to_time
time = Time.new

    respond_to do |format|
      if @po.save
        format.xml { render :xml => "Success " + time.strftime("%Y-%m-%d %H:%M:%S") }
        format.html { redirect_to(@po, :notice => 'Po was successfully created.') }
        #format.xml  { render :xml => @po, :status => :created, :location => @po }
      else
        format.xml { render :xml => "Failed to save position in DB" }
        #format.xml  { render :xml => @po.errors, :status => :unprocessable_entity }
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /pos/1
  # PUT /pos/1.xml
  def update
    @po = Po.find(params[:id])

    respond_to do |format|
      if @po.update_attributes(params[:po])
        format.html { redirect_to(@po, :notice => 'Po was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @po.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /pos/1
  # DELETE /pos/1.xml
  def destroy
    @po = Po.find(params[:id])
    @po.destroy

    respond_to do |format|
      format.html { redirect_to(pos_url) }
      format.xml  { head :ok }
    end
  end
end
