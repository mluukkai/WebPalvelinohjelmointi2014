require 'spec_helper'

describe Beer do
  it "is saved when name and style are nonempty" do
    beer = Beer.create name:"Karhu", style:FactoryGirl.create(:style)

    expect(beer).to be_valid
    expect(Beer.count).to eq(1)
  end

  describe "is not saved" do
    it "if name missing" do
      beer = Beer.create style:FactoryGirl.create(:style)

      expect(beer).not_to be_valid
      expect(Beer.count).to eq(0)
    end

    it "if style missing" do
      beer = Beer.create name:"Karhu"

      expect(beer).not_to be_valid
      expect(Beer.count).to eq(0)
    end
  end
end
