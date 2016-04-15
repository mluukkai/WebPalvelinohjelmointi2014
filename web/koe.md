# Web-palvelinohjelmointi Ruby on Rails, uusintaikoe 16.4.2016

*Kaikki tehtävät liittyvät koepaperin lopusta löytyvään koodiin.*

Kirjoita jokaiseen palauttamaasi paperiin nimesi ja opiskelijanumerosi  sekä kurssin nimi.

**Selitä jokaisessa tehtävässä asiat kooditasolla *sekä* abstraktimmalla tasolla, eli selitä myös mikä on kunkin tehtävän kannalta relevantin sovelluksen komponentin rooli toiminnallisuuden kannalta.** 

## tehtävä 1 (3p)

Tapahtuu HTTP GET -pyyntö osoitteeseen _http://localhost:3000/teams/1_ 

Selitä tarkasti mitä tapahtuu kun pyyntö saavuttaa sovelluksen (voit olettaa että pyyntö onnistuu).

Kerro samalla mitä tarkoittaa _MVC-arkkitehtuuri_ ja miten se liittyy sovelluksen _tämän tehtävän kannalta_ relevantteihin komponentteihin.

## tehtävä 2 (5p)

Käyttäjä on navigoinut uuden joukkueen luomissivulle:

![kuva](https://github.com/mluukkai/wadror2014-stage/raw/master/koe/kuva2.png)
Kerro mitä kaikkea sovelluksessa tapahtuu lomakkeen (views/teams/new.html.erb) lähettämisen seurauksena.

Kerro myös tarkasti mitä tapahtuu, jos joukkueen luominen epäonnistuu, ja mikä voi aiheuttaa epäonnistumisen (voit jättää huomioimatta tietoliikenneprotokollan tai palvelimen tasolla tapahtuvat ongelmat).

## tehtävä 3 (4p)

Kaikkien joukkueiden sivun _http://localhost:3000/teams_ näyttää seuraavalta:

![kuva](https://github.com/mluukkai/wadror2014-stage/raw/master/koe/kuva3.png)

Sivun toteutus ei ole tällä hetkellä suorituskyvyltään erityisen hyvä. Jos joukkueita olisi tuhansia ja pelaajia kymmeniä tuhansia, olisi sivu todennäköisesti erittäin hidas.

Kerro mitä ongelmia sivun toteutuksessa on 
suorituskyvyn kannalta ja millä Railsin tarjoamilla 
tekniikoilla näitä voidaan optimoida?
Mitkä ovat kunkin optimointitekniikan hyvät ja huonot puolet? Mitä muutoksia näiden käyttöönotto edellyttäisi koodin tasolla?

## tehtävä 4 (3p)

Selitä miten sovellusta laajennettaisiin siten, että mukaan tuotaisiin uusi käsite _liiga_ (League). Liigalla on nimi ja perustamisvuosi. Liiga sisältää useita joukkueita ja joukkueet voivat kuulua yhtäaikaa useaan eri liigaan.

Vastauksessa ei ole tarvetta kertoa näyttöjen ja kontrollerien osalta tarvittavia muutoksia.
Kiinnostuksen kohteena ovat nyt erityisesti laajennuksen aiheuttamat muutokset modeleihin ja tietokantatasolle sekä se miten nämä toteutetaan.

```ruby
# config/routes.rb

ExamApp::Application.routes.draw do
  resources :players

  get '/teams', to:'teams#index'
  get '/teams/new', to:'teams#new'
  post '/teams', to:'teams#create'
  get '/teams/:id', to:'teams#show'
end

# app/controllers/teams_controller.rb

class TeamsController < ApplicationController

  def index
    @teams = Team.all
  end

  def show
    @team = Team.find(params[:id])
  end

  def new
    @team = Team.new
  end

  def create
    @team = Team.new(params.require(:team).permit(:name))

    if @team.save
      redirect_to teams_path, notice: 'Team was successfully created.' 
    else
      render 'new'
    end
  end

end

# app/models/team.rb

class Team < ActiveRecord::Base
	has_many :players

 	validates :name, uniqueness: true,
                     length: { minimum: 3 }

    def total_goals
    	players.inject(0) { |sum, p| sum+p.goals}              	
    end              
end

# db/migrate/20140215142931_create_teams_and_players.rb

class CreateTeamsAndPlayers < ActiveRecord::Migration
  def change
    create_table :teams do |t|
      t.string :name
    end

    create_table :players do |t|
      t.string :name
      t.integer :goals
      t.integer :team_id
    end
  end
end
```

```erb
# app/views/teams/index.html.erb

<h1>Teams</h1>

<ul>
  <% @teams.each do |team| %>
    <li> <%= team.name %> goals total <%= team.total_goals %> </li>
  <% end %>
</ul>

# app/views/teams/new.html.erb

<h1>Create a new team</h1>

<%= form_for(@team) do |f| %>
  <% if @team.errors.any? %>
      <% @team.errors.full_messages.each do |msg| %>
        <p><%= msg %></p>
      <% end %>
  <% end %>

  Name: <%= f.text_field :name %> <br>
  <%= f.submit %>
<% end %>

# app/views/teams/show.html.erb

<h2> <%= @team.name %> </h2>

<ul>
  <% @team.players.each do |player| %>
    <li> <%= player.name %> </li>
  <% end %>
</ul>
```

