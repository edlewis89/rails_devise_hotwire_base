require 'rails_helper'

RSpec.describe "homeowners/show", type: :view do
  before(:each) do
    assign(:homeowner, Homeowner.create!(
      name: "Name",
      description: "MyText"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/MyText/)
  end
end
