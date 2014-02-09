require 'spec_helper'

include OwnTestHelper

describe "User" do
  let!(:user){FactoryGirl.create :user}

  describe "who has signed up" do
    it "can signin with right credentials" do
      sign_in(username:"Pekka", password:"Foobar1")

      expect(page).to have_content 'Welcome back!'
      expect(page).to have_content 'Pekka'
    end

    it "is redirected back to signin form if wrong credentials given" do
      sign_in(username:"Pekka", password:"wrong")

      expect(current_path).to eq(signin_path)
      expect(page).to have_content 'username and password do not match'
    end
  end

  it "when signed up with good credentials, is added to the system" do
    visit signup_path
    fill_in('user_username', with:'Brian')
    fill_in('user_password', with:'Secret55')
    fill_in('user_password_confirmation', with:'Secret55')

    expect{
      click_button('Create User')
    }.to change{User.count}.by(1)
  end

  it "favorite beer, style and brewery shown at page" do
    koff = FactoryGirl.create(:brewery, name:"Koff")
    best = FactoryGirl.create(:beer, name:"iso 3", style:"Lager", brewery:koff)
    FactoryGirl.create(:rating, score:30, beer:best, user:user)

    create_beers_with_ratings(10, 15, 20, user)

    visit user_path(user)

    expect(page).to have_content 'Favorite beer: iso 3'
    expect(page).to have_content 'Favorite brewery: Koff'
    expect(page).to have_content 'Preferred style: Lager'
  end
end