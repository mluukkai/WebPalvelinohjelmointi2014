require 'spec_helper'

include OwnTestHelper

describe User do
  it "has the username set correctly" do
    user = User.new username:"Pekka"

    user.username.should == "Pekka"
  end

  describe "is not saved when password" do
    it "is missing" do
      user = User.create :username => "Pekka"

      expect(user).not_to be_valid
      expect(User.count).to eq(0)
    end

    it "is too short" do
      user = User.create username:"Pekka", password:"S1", password_confirmation:"S1"

      expect(user).not_to be_valid
      expect(User.count).to eq(0)
    end

    it "is invalid" do
      user = User.create username:"Pekka", password:"secret1", password_confirmation:"secret1"

      expect(user).not_to be_valid
      expect(User.count).to eq(0)
    end
  end

  describe "with a proper password" do
    let(:user){ FactoryGirl.create(:user) }

    it "is saved" do
      expect(user).to be_valid
      expect(User.count).to eq(1)
    end

    it "and with two ratings, has the correct average rating" do
      user.ratings << FactoryGirl.create(:rating)
      user.ratings << FactoryGirl.create(:rating2)

      expect(user.ratings.count).to eq(2)
      expect(user.average_rating).to eq(15.0)
    end
  end

  describe "favorite beer" do
    let(:user){FactoryGirl.create(:user) }

    it "has method for determining one" do
      user.should respond_to :favorite_beer
    end

    it "without ratings does not have one" do
      expect(user.favorite_beer).to eq(nil)
    end

    it "is the only rated if one rating" do
      beer = create_beer_with_rating(10, user)

      expect(user.favorite_beer).to eq(beer)
    end

    it "is the one with highest rating if several rated" do
      create_beers_with_ratings(10, 20, 15, 7, 9, user)
      best = create_beer_with_rating(25, user)

      expect(user.favorite_beer).to eq(best)
    end
  end

  describe "favorite style" do
    let(:user){FactoryGirl.create(:user) }

    it "has method for determining one" do
      user.should respond_to :favorite_style
    end

    it "without ratings does not have one" do
      expect(user.favorite_style).to eq(nil)
    end

    it "is the style of the only rated if one rating" do
      favorite = FactoryGirl.create(:style)
      create_beers_with_ratings_and_style(10, favorite, user)

      expect(user.favorite_style).to eq(favorite)
    end

    it "is the style with highest average rating if several rated" do
      favorite = FactoryGirl.create(:style)

      create_beers_with_ratings_and_style(10, 20, 15, FactoryGirl.create(:style), user)
      create_beers_with_ratings_and_style(35, favorite = FactoryGirl.create(:style), user)
      create_beers_with_ratings_and_style(25, 20, 15, FactoryGirl.create(:style), user)

      expect(user.favorite_style).to eq(favorite)
    end
  end

  describe "favorite brewery" do
    let(:user){FactoryGirl.create(:user) }

    it "has method for determining one" do
      user.should respond_to :favorite_brewery
    end

    it "without ratings does not have one" do
      expect(user.favorite_brewery).to eq(nil)
    end

    it "is the brewery of only rated if one rating" do
      brewery = FactoryGirl.create(:brewery, name:"Koff")
      create_beers_with_ratings_and_brewery(10, brewery, user)

      expect(user.favorite_brewery).to eq(brewery)
    end

    it "is the brewery with highest average rating if several rated" do
      plevna = FactoryGirl.create(:brewery, name:"Plevna")
      create_beers_with_ratings_and_brewery(10, 20, 15, FactoryGirl.create(:brewery), user)
      create_beers_with_ratings_and_brewery(35, plevna , user)
      create_beers_with_ratings_and_brewery(25, 20, 15, FactoryGirl.create(:brewery), user)

      expect(user.favorite_brewery).to eq(plevna)
      end
  end

end


