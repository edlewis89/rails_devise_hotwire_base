require 'rails_helper'

RSpec.describe "homeowners/new", type: :view do
  before(:each) do
    assign(:homeowner, Homeowner.new(
      name: "MyString",
      description: "MyText"
    ))
  end

  it "renders new homeowner form" do
    render

    assert_select "form[action=?][method=?]", homeowners_path, "post" do

      assert_select "input[name=?]", "homeowner[name]"

      assert_select "textarea[name=?]", "homeowner[description]"
    end
  end
end
