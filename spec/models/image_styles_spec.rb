require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Asset do
  include ActionController::TestProcess
  before :each do
    @schema = JsonObject::Schema.new
    @schema.fields << JsonObject::Types::Asset.new(
      'styles' => [{'key' => 'oans', 'style' => '200x'}])
    @params = HashWithIndifferentAccess.new(
      "Filename"=>"localhorst.jpg",
      "schema"=>{
        "class"=>"Category",
        "id"=>"3",
        "uid"=>"ae102bf2-c56e-11de-a61c-21cc9a9e4ca2",
        "attribute"=>"schema"},
      "parent_type"=>"Document",
      "upload_type"=>"asset",
      "action"=>"create",
      "Upload"=>"Submit Query",
      "vrame_styles"=>{"droa"=>"300x", "oans"=>"100x", "zwoa"=>"200x"},
      "parent_id"=>"4",
      "controller"=>"vrame/assets",
      "Filedata"=> fixture_file_upload('localhorst.jpg', 'image/jpeg'))
  end
  
  after :each do
    @asset.destroy if @asset
  end
  
  it "should determine the styles through the schema param" do
    @params.delete('vrame_styles')
    @params['schema']['uid'] = @schema.fields[0].uid
    
    Category.should_receive(:find).with('3').and_return(mock("Category", :schema => @schema))
    styles = JsonObject::Types::Asset.styles_for(@params['schema'])
    styles.should eql({'oans' => '200x'})
  end
  
  it "should create an image model from image files" do
    @params[:file] = @params[:Filedata]
    @asset = Asset.factory(@params)
    @asset.should be_instance_of(Image)
  end

  it "should create an asset model from non-image files" do
    @params[:file] = fixture_file_upload('languages.yml', 'text/plain')
    @asset = Asset.factory(@params)
    @asset.should be_instance_of(Asset)
    @asset.should_not be_instance_of(Image)
  end

  it "should create image options as provided in the vrame_styles parameter" do
    @params[:file] = @params[:Filedata]
    @asset = Asset.factory(@params)
    @asset.file.styles['oans'][:geometry].should eql('100x')
    @asset.file.styles['zwoa'][:geometry].should eql('200x')
    @asset.file.styles['droa'][:geometry].should eql('300x')
  end
end
