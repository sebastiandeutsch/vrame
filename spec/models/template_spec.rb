require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Document, "#render_options()" do
  it "should provide the category's document_template if its template is blank"
  it "should provide the category's document_layout   if its layout   is blank"
  
  it "should not return a template option if all templates are blank"
  it "should not return a layout   option if all layouts   are blank"
end
