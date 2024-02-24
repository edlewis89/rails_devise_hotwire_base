require 'rails_helper'

RSpec.describe "homeowners/edit", type: :view do
  let(:homeowner) {
    Homeowner.create!(
      name: "MyString",
      description: "MyText"
    )
  }

  before(:each) do
    assign(:homeowner, homeowner)
  end

  it "renders the edit homeowner form" do
    render

    assert_select "form[action=?][method=?]", homeowner_path(homeowner), "post" do

      assert_select "input[name=?]", "homeowner[name]"

      assert_select "textarea[name=?]", "homeowner[description]"
    end
  end
end
