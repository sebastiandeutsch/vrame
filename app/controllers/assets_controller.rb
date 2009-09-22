class AssetsController < ApplicationController
  
  def download
    @asset = Asset.find(params[:id])
    
    @path = @asset.file.path.gsub(File.join(RAILS_ROOT, 'public'), '')
    
    head :x_accel_redirect    => @path,
         :content_type        => @asset.file.content_type,
         :content_disposition => "attachment; filename=#{@asset.file_file_name}"
  end
  
end