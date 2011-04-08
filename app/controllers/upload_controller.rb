class UploadController < ApplicationController
  def index
     render :file => 'app\views\upload\uploadfile.rhtml'
  end
  def uploadFile
    puts params.inspect
    post = DataFile.save(params[:datafile])
    render :text => "File has been uploaded successfully"
  end
end
