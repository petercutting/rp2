class BbsController < ApplicationController


  # GET /bbs
  # GET /bbs.xml
  def index
    @bbs = Bb.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @bbs }
    end
  end

  # GET /bbs/1
  # GET /bbs/1.xml
  def show
    @bb = Bb.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @bb }
    end
  end

  # GET /bbs/new
  # GET /bbs/new.xml
  def new
    @bb = Bb.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @bb }
    end
  end

  # GET /bbs/1/edit
  def edit
    @bb = Bb.find(params[:id])
  end


#{"latitude"=>"55.589842", "accuracy"=>"1174.0", "altitude"=>"0.0", "time"=>"2011-03-14T21:22:43.
#987Z", "bearing"=>"0.0", "speed"=>"0.0", "longitude"=>"12.943554", "charging"=>"1", "battlevel"=>"46", "provid
#er"=>"network"}

  # POST /bbs
  # POST /bbs.xml
  def create
    puts 'create.xml ' + params[:path].inspect

    @bb = Bb.new(params[:bb])

    respond_to do |format|
      if @bb.save
        format.html { redirect_to(@bb, :notice => 'Bb was successfully created.') }
        format.xml  { render :xml => @bb, :status => :created, :location => @bb }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @bb.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /bbs/1
  # PUT /bbs/1.xml
  def update
    @bb = Bb.find(params[:id])

    respond_to do |format|
      if @bb.update_attributes(params[:bb])
        format.html { redirect_to(@bb, :notice => 'Bb was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @bb.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /bbs/1
  # DELETE /bbs/1.xml
  def destroy
    @bb = Bb.find(params[:id])
    @bb.destroy

    respond_to do |format|
      format.html { redirect_to(bbs_url) }
      format.xml  { head :ok }
    end
  end
end
