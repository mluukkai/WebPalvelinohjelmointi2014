require 'spec_helper'

include OwnTestHelper

describe "Beer" do
  let!(:brewery) { FactoryGirl.create(:brewery, name:"Koff") }
  let!(:style) { FactoryGirl.create(:style) }

  before :each do
    FactoryGirl.create :user
    sign_in(username:"Pekka", password:"Foobar1")
  end

  it "is created when a valid name given" do
    visit new_beer_path
    fill_in('beer_name', with:'Arrogant Bastard Ale')

    expect{
      click_button('Create Beer')
    }.to change{Beer.count}.by(1)
  end

  it "is not created with invalid name" do
    visit new_beer_path

    expect{
      click_button('Create Beer')
    }.to change{Beer.count}.by(0)
    expect(page).to have_content "Name can't be blank"
    expect(page).to have_content "New beer"
  end
end