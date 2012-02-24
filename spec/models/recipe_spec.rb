require "spec_helper"

describe Recipe do
  let(:basic_all_grain) {Recipe.create(:batch_number => 9999, :name => 'basic all grain', :xml => File.open('test/fixtures/xmls/basic-all-grain.xml'))}

  it {should have_attached_file(:xml)}  
  it {should validate_attachment_presence(:xml)}
  
  it "should require batch number be unique" do
    basic_all_grain.batch_number.should == 9999
    duplicate_number = Recipe.new(:batch_number => 9999, :name => 'basic all grain', :xml => File.open('test/fixtures/xmls/basic-all-grain.xml'))
    duplicate_number.valid?.should be_false
  end
  
  it "should order recipes by batch number"
  
  it "should should sort additions by time added"
  
  it "should return batch size in litres"
  
  
end