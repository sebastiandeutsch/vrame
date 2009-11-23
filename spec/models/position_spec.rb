require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Category do
  before :each do
    Category.delete_all
    @root = Category.create!(:title => "root")
    @cat1 = Category.create!(:title => "cat1", :parent => @root)
    @cat2 = Category.create!(:title => "cat2", :parent => @root)
    
    (1..5).each do |nr|
      Category.create!(:title => "Kategorie #{nr}", :parent => @cat1)
    end
    Category.create!(:title => "Querulant 6", :parent => @cat2)
    (6..10).each do |nr|
      Category.create!(:title => "Kategorie #{nr}", :parent => @cat1)
    end
  end
  
  it "should have position 1 twice" do
    Category.find_all_by_position("1").should have(4).categories
  end
  
  it "should not have positions twice inside cat1 after moving the querulant" do
    q = Category.find_by_title("Querulant 6")
    q.parent = @cat1
    q.save!
    @cat1 = Category.find_by_title("cat1")
    cats = @cat1.children
    positions = []
    cats.each do |cat|
      positions.should_not include(cat.position)
      positions << cat.position
    end
  end
end
