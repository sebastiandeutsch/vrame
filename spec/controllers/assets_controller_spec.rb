require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Vrame::AssetsController do
  before :each do
    @schema = JsonObject::Schema.new
    @schema.fields << JsonObject::Types::Asset.new(
      'styles' => [{'key' => 'oans', 'style' => '200x'}])
    @params = HashWithIndifferentAccess.new(
      "Filename"=>"localhorst.jpg",
      "schema"=>{
        "class"=>"Category",
        "id"=>"3",
        "uid"=>@schema.fields[0].uid,
        "attribute"=>"schema"},
      "parent_type"=>"Document",
      "upload_type"=>"asset",
      "action"=>"create",
      "Upload"=>"Submit Query",
      "parent_id"=>"4",
      "controller"=>"vrame/assets",
      "Filedata"=> fixture_file_upload('localhorst.jpg', 'image/jpeg'))
    # @session = {:admin_current_language_id}
    controller.should_receive(:choose_language).and_return(true)
  end
  
  after(:each) do
    @asset.destroy if @asset
  end
  
  it "should generate the correct image versions" do
    @asset = Asset.factory(@params.merge({'file' => @params['Filedata'], 'vrame_styles' => {'oans' => '200x'} }))
    Category.should_receive(:find).with('3').and_return(mock("Category", :schema => @schema))
    Asset.should_receive(:factory).with {|params|
      params.should have_key(:vrame_styles)
      params[:vrame_styles]['oans'].should eql('200x')
    }.and_return(@asset)

    post :create, @params    
  end
end