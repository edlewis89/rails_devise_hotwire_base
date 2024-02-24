require 'rails_helper'

RSpec.describe "contractors/new", type: :view do
  before(:each) do
    assign(:contractor, Contractor.new(
      name: "MyString",
      description: "MyText"
    ))
  end

  it "renders new contractor form" do
    render

    assert_select "form[action=?][method=?]", contractors_path, "post" do

      assert_select "input[name=?]", "contractor[name]"

      assert_select "textarea[name=?]", "contractor[description]"
    end
  end
end
