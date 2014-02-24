require 'spec_helper'

describe "beerlist page" do

  before :all do
    self.use_transactional_fixtures = false
    WebMock.disable_net_connect!(allow_localhost:true)
  end

  before :each do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.start

    @brewery1 = FactoryGirl.create(:brewery, name: "Koff")
    @brewery2 = FactoryGirl.create(:brewery, name: "Schlenkerla")
    @brewery3 = FactoryGirl.create(:brewery, name: "Ayinger")
    @style1 = Style.create name: "Lager"
    @style2 = Style.create name: "Rauchbier"
    @style3 = Style.create name: "Weizen"
    @beer1 = FactoryGirl.create(:beer, name: "Nikolai", brewery: @brewery1, style: @style1)
    @beer2 = FactoryGirl.create(:beer, name: "Fastenbier", brewery: @brewery2, style: @style2)
    @beer3 = FactoryGirl.create(:beer, name: "Lechte Weisse", brewery: @brewery3, style: @style3)
  end

  after :each do
    DatabaseCleaner.clean
  end

  after :all do
    self.use_transactional_fixtures = true
  end

  it "shows one known beer", js: true do
    visit beerlist_path
    expect(page).to have_content "Nikolai"
  end

  it "orders by default alphabetically", js:true do
    visit beerlist_path
    expect_order_to_be 'Fastenbier', 'Lechte Weisse', 'Nikolai'
  end

  it "orders by brewery", js:true do
    visit beerlist_path
    click_link 'Brewery'
    expect_order_to_be 'Lechte Weisse', 'Nikolai', 'Fastenbier'
  end

  it "orders by stryle", js:true do
    visit beerlist_path
    click_link 'Style'
    expect_order_to_be 'Nikolai', 'Fastenbier', 'Lechte Weisse'
  end
end

def expect_order_to_be(beer1, beer2, beer3)
  find('table').find('tr:nth-child(2)').should have_content(beer1)
  find('table').find('tr:nth-child(3)').should have_content(beer2)
  find('table').find('tr:nth-child(4)').should have_content(beer3)
end
