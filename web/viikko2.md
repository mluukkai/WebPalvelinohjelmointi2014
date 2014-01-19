Jatkamme sovelluksen rakentamista siitä, mihin jäimme viikon 1 lopussa. Allaoleva materiaali olettaa, että olet tehnyt kaikki edellisen viikon tehtävät. Jos et tehnyt kaikkia tehtäviä, voit ottaa kurssin repositorioista edellisen viikon mallivastauksen (ilmestyy 20.1. klo 00:01). Jos sait suurimman osan edellisen viikon tehtävistä tehtyä, saattaa olla helpointa, että täydennät vastaustasi mallivastauksen avulla.


Jos otat edellisen viikon mallivastauksen tämän viikon pohjaksi, kopioi hakemisto pois kurssirepositorion alta (olettaen että olet kloonannut sen) ja tee sovelluksen sisältämästä hakemistosta uusi repositorio.

## Sovelluksen layout

Haluamme laittaa sivulle modernien web-sivustojen tyyliin navigointipalkin eli sijoittaa sovelluksen _kaikkien_ sivujen ylälaitaan linkit oluiden ja panimoiden listoihin.

Navigointipalkki saadaan generoitua helposti metodin <code>link_to</code> ja polkuapumetodien avulla lisäämällä jokaiselle sivulle seuraavat linkit:

```erb
<%= link_to 'breweries', breweries_path %>
<%= link_to 'beers', beers_path %>
```

Tarkkasilmäisimmät saattoivat jo viime viikolla huomata, että näkymätemplatet eivät sisällä kaikkea sivulle tulevaa HTML-koodia. Esim. yksittäisen oluen näkymätemplate /app/views/beers/show.html.erb on seuraava:

```erb
<p id="notice"><%= notice %></p>

<p>
  <strong>Name:</strong>
  <%= @beer.name %>
</p>

<p>
  <strong>Style:</strong>
  <%= @beer.style %>
</p>

<p>
  <strong>Brewery:</strong>
  <%= @beer.brewery_id %>
</p>

<%= link_to 'Edit', edit_beer_path(@beer) %> |
<%= link_to 'Back', beers_path %>
```

Jos katsomme yksittäisen oluen sivun HTML-koodia selaimen _view source code_ -toiminnolla, huomaamme, että sivulla on paljon muutakin kuin templatessa määritelty HTML (osa headin sisällöstä on poistettu):

```erb

<!DOCTYPE html>
<html>
<head>
  <title>Ratebeer</title>
  <link data-turbolinks-track="true" href="/assets/application.css?body=1" media="all" rel="stylesheet" />
  <script data-turbolinks-track="true" src="/assets/jquery.js?body=1"></script>
  <meta content="authenticity_token" name="csrf-param" />
<meta content="hZaC8o95xUbekA3PTsVZ+JmkVj9CCn5a4Kw8tF96WOU=" name="csrf-token" />
</head>
<body>

<p id="notice"></p>

<p>
  <strong>Name:</strong>
  Iso 3
</p>

<p>
  <strong>Style:</strong>
  Lager
</p>

<p>
  <strong>Brewery:</strong>
  1
</p>

<a href="/beers/1/edit">Edit</a> |
<a href="/beers">Back</a>


</body>
</html>
```

Sivu sisältää siis dokumentin tyypin määrittelyn, käytettävät tyylitiedostot ja javascript-tiedostot määrittelevän head-elementin ja sivun sisällön määrittelevän body-elementin (ks. lisää http://www.w3.org/community/webed/wiki/HTML/Training).

Oluen sivun näkymätemplate siis sisältää ainoastaan body-elementin sisälle tulevan HTML-koodin.

On tyypillistä, että sovelluksen kaikki sivut ovat body-elementin sisältöä lukuunottamatta samat. Railissa saadaankin määriteltyä kaikille sivuille yhteiset osat sovelluksen _layoutiin_, eli tiedostoon app/views/layouts/application.html.erb. Oletusarvoisesti tiedoston sisältö on seuraavanlainen:

```erb
<!DOCTYPE html>
<html>
<head>
  <title>Ratebeer</title>
  <%= stylesheet_link_tag    "application", media: "all", "data-turbolinks-track" => true %>
  <%= javascript_include_tag "application", "data-turbolinks-track" => true %>
  <%= csrf_meta_tags %>
</head>
<body>

<%= yield %>

</body>
</html>
```

Head-elementin sisällä olevat apumetodit määrittelevät sovelluksen käyttämät tyyli- ja javascript-tiedostot, apumetodi <code>csrf_meta_tags</code> lisää sivulle CSRF-hyökkäykset eliminoivan logiikan 
(ks. tarkemmin esim. [täältä](http://stackoverflow.com/questions/9996665/rails-how-does-csrf-meta-tag-work)). Kuten arvata saattaa, body-elementin sisällä olevan komennon <code>yield</code>-kohdalle renderöityy kunkin sivun oman näkymätemplaten määrittelemä sisältö.

Saamme navigointipalkin näkyville kaikille sivuille muuttamalla sovelluksen layoutin body-elementtiä seuraavasti:

```erb
<body>
  <div class="navibar">
    <%= link_to 'breweries', breweries_path %>
    <%= link_to 'beers', beers_path %>
  </div>

  <%= yield %>

</body>
```
 
Navigointipalkki on laitettu luokan _navibar_ sisältävän div-elementin sisällä, joten sen ulkoasua voidaan halutessa muotoilla css:n avulla.

Lisää tiedostoon app/assets/stylesheets/application.css seuraava:

```erb
.navibar {
    padding: 10px;
    background: #EFEFEF;
}
```

Kun reloadaan sivun, huomaat, että sovelluksesi antama vaikutelma on jo melko professionaali.

## routes.rb

Railsin Routing-komponentin 
(ks. http://api.rubyonrails.org/classes/ActionDispatch/Routing.html, http://guides.rubyonrails.org/routing.html) vastuulla on ohjata eli reitittää sovellukselle tulevien HTTP-pyyntöjen käsittely sopivan kontrollerin metodille.

Tieto siitä miten eri URLeihin tulevat pyynnöt tulee reitittää, konfiguroidaan tiedostoon config/routes.rb. Tässä vaiheessa tiedoston sisältö on seuraavanlainen: 

```ruby
Ratebeer::Application.routes.draw do
  resources :beers
  resources :breweries
end
```

Tutustumme myöhemmin <code>resources</code>-metodin lisäämiin reitteihin.

Aloitetaan sillä, että tehdään panimoiden listasta sovelluksen oletusarvoinen kotisivu. Poistetaan ensin tiedosto public/index.html ja lisätään routes-tiedostoon rivi 

    root 'breweries#index'

Nyt osoite http://localhost:3000/ ohjautuu kaikki panimot näyttävälle sivulle.

Edellinen on oikeastana hieman tyylikkäämpi tapa sanoa:

    get '/', to: 'breweries#index'

eli reititä polulle '/' tuleva HTTP GET -pyyntö käsiteltäväksi luokan <code>BreweriesController</code> metodille <code>index</code>.

Englanninkielistä kirjallisuutta lukiessa kannattaa huomata, että Railsin terminologiassa kontrollereiden metodeja nimitetään usein actioneiksi. Käytämme kuitenkin kurssilla nimitystä kontrollerimetodi tai kontrollerin metodi. 

Voisimme vastaavasti lisätä routes.rb:hen rivin

    get 'kaikki_bisset', to: 'beers#index'

jolloin URLiin http://localhost:3000/kaikki_bisset tulevat GET-pyynnöt vievät kaikkien oluiden sivulle. Kokeile että tämä toimii.

Mielenkiintoinen yksityiskohta routes.rb-tiedostossa on se, että vaikka tiedosto näyttää tekstimuotoiselta konfiguraatiotiedostolta, on koko tiedoston sisältö Rubyä. Tiedoston rivit ovat metodikutsuja. Esim. rivi

    get 'kaikki_bisset', to: 'beers#index'

kutsuu get-metodia parametreinaan merkkijono '/kaikki_bisset' ja hash <code>to: 'beers#index'</code>. Hashin yhteydessä on käytetty uudempaa syntaksia, eli vanhaa syntaksia käyttäen reitityksen kohteen määrittelevä hash kirjoitettaisiin <code>:to => 'beers#index'</code>, ja routes.rb:n rivi olisi:

    get 'kaikki_bisset', :to => 'beers#index'

voisimme käyttää metodikutsussa myös sulkuja, ja määritellä hashin käyttäen aaltosulkuja, eli kömpelöimmässä muodossa reitti voitaisiin määritellä seuraavasti:

    get( 'kaikki_bisset', { :to => 'beers#index' } ) 
    
Rubyn joustava syntaksi (yhdessä kielen muutamien muiden piirteiden kanssa) mahdollistaakin luonnollisen kielen sujuvuutta tavoittelevan ilmaisutavan  sovelluksen konfigurointiin ja ohjelmointiin. Tyyli tunnetaan englanninkielisellä termillä _Internal DSL_ ks. http://martinfowler.com/bliki/InternalDslStyle.html  

## Oluiden pisteytys

Lisätään seuraavaksi ohjelmaan mahdollisuus antaa oluille "reittauksia" eli pisteytyksiä skaalalla 0-50. Emme käytä viime viikolta tuttua generaattoria (<code>rails generate scaffold...</code>) vaan teemme kaiken itse.

Haluamme että kaikki reittaukset ovat osoitteessa http://localhost:3000/ratings. Kokeillaan nyt selaimella mitä tapahtuu kun urliin yritetään mennä.

Seurauksena on virheilmoitus <code>No route matches [GET] "/ratings"</code> eli osoitteeseen tehtyä HTTP GET -pyyntöä ei vastannut mikään määritelty "reitti".

Lisätään reitti kirjoittamalla routes-tiedostoon seuraava:

    get 'ratings', to: 'ratings#index'

Määrittelemme siis Rails-konventiota mukaillen, että kaikkien reittausten sivun 'ratings' hoitaa RatingsController-luokan metodi index.

Huom: suunilleen samaa tarkoittaisi myös <code>match 'ratings' => 'ratings#index'</code>. Kuten niin tyypillistä Railsille, voi routes.rb:ssäkin käyttää saman asian määrittelemiseen monia erilaisia tapoja.

Kokeile nyt sivua uudelleen selaimella.

Virheilmoitus muuttuu muotoon <code>uninitialized constant RatingsController</code> eli määritelty reitti yrittää ohjata ratings-osoitteeseen tulevan GET-kutsun <code>RatingsController</code>-luokassa määritellyn kontrollerin metodin <code>index</code>-käsiteltäväksi.

Määritellään kontrolleri tiedostoon /app/controllers/ratings_controller.rb.

```ruby
class RatingsController < ApplicationController
  def index
  end
end
```

Huomioi nimeämiskäytännöt ja tiedoston sijainti, Rails etsii kontrolleria nimenomaan hakemistosta /app/controllers. Jos sijoitat kontrollerin muualle, ei Rails löydä sitä.

Kokeile nyt sivua selaimella vielä kerran.

Seurauksena on uusi virheilmoitus 

	Missing template ratings/index, application/index with {:locale=>[:en], :formats=>[:html], :handlers=>[:erb, :builder, :raw, :ruby, :jbuilder, :coffee]}. Searched in: * "/Users/mluukkai/kurssirepot/wadror/ratebeer/app/views"

joka taas johtuu siitä, että Rails yrittää renderöidä kontrollerin metodia vastaavan oletusarvoisen, hakemistossa /app/views/ratings/index.html.erb olevan näkymätemplaten, mutta sellaista ei löydy. 

Luodaan tiedosto /app/views/ratings/index.html.erb jolla on seuraava sisältö:

```erb
<h2>List of ratings</h2>

<p>To be completed...</p>
```

ja nyt sivu toimii!

Huomaa taas Railsin konventiot, tiedoston sijainti on tarkasti määritelty, eli koska kyseessä on näkymätemplate jota kutsutaan ratings-kontrollerista (joka siis on täydelliseltä nimeltään RatingsController), sijoitetaan se hakemistoon /views/ratings. 

Muistutuksena vielä [viimeviikosta](https://github.com/mluukkai/WebPalvelinohjelmointi2014/blob/master/web/viikko1.md#kontrollerin-ja-viewien-yhteys): kontrollerimetodi <code>index</code> renderöi oletusarvoisesti suorituksensa lopuksi (oikeassa hakemistossa olevan) index-nimisen näkymän. Eli koodi  

```ruby
class RatingsController < ApplicationController
  def index
  end
end
```

tekee oikeastaan siis saman asian kuin seuraava:

```ruby
class RatingsController < ApplicationController
  def index
    render :index    # renderöin näkymätemplate /app/views/ratings/index.html
  end
end
```

Eksplisiittinen render-metodin kutsu jätetään kuitenkin yleensä pois jos renderöidään oletusarvoinen, eli kontrollerimetodin kanssa samanniminen template. 

## Modelin teko käsin, melkein...

Yhteen olueeseen liittyy useita reittauksia, eli oliomalli pitää päivittää seuraavanlaiseksi:

![olueeseen liittyy reittauksia](http://yuml.me/4ef16c6a)

Tarvitsemme siis tietokantataulun ja vastaavan model-olion. 

Railsissa muutokset tietokantaan, esim. uuden taulun lisääminen, kannattaa tehdä __aina__ migraatioiden avulla. Migraatiot ovat siis hakemistoon db/migrate sijoitettavia tiedostoja, joihin kirjoitetaan Rubyllä tietokantaa muokkaavat operaatiot. Tutustumme migraatioihin tarkemmin vasta myöhemmin ja käytämme modelin luomiseen nyt Railsin valmista _model-generaattoria_, joka luo model-olion lisäksi automaattisesti tarvittavan migraation.

Reittauksella on kokonaislukuarvoinen code>score</code> sekä vierasavain, joka linkittää sen reitattuun olueeseen. Railsin konvention mukaan vierasavaimen nimen tulee olla <code>beer_id</code>.

Model ja tietokannan generoiva migraatio saadaan luotua antamalla komentoriviltä komento:

    rails g model Rating score:integer beer_id:integer

ja luodaan tietokantataulu suorittamalla komentoriviltä migraatio

    rake db:migrate

Toisin kuin viime viikolla käyttämämme _scaffold_-generaattori, model-generaattori ei luo ollenkaan kontrolleria eikä näkymätemplateja.

Jotta yhteydet saadaan myös oliotasolle (muistutuksena [viime viikon materiaali](https://github.com/mluukkai/WebPalvelinohjelmointi2014/blob/master/web/viikko1.md#oluet-ja-yhden-suhde-moneen--yhteys), tulee luokkia päivittää seuraavasti

```ruby
class Beer < ActiveRecord::Base
  belongs_to :brewery
  has_many :ratings
end

class Rating < ActiveRecord::Base
  belongs_to :beer
end
```

Eli jokaiseen olueeseen liittyy useita reittauksia ja reittaus kuuluu aina täsmälleen yhteen olueeseen.

Käynnistetään Rails-konsoli antamalla komentoriviltä komento <code>rails c</code>. Huomaa, että jos konsolisi oli jo auki, saat lisätyn koodin konsolin käyttöön komennolla <code>reload!</code>. Luodaan muutama reittaus:

```ruby
irb(main):001:0> b = Beer.first
irb(main):002:0> b.ratings.create score:10
irb(main):003:0> b.ratings.create score:21
irb(main):004:0> b.ratings.create score:17
irb(main):005:0> b.ratings
  Rating Load (0.3ms)  SELECT "ratings".* FROM "ratings" WHERE "ratings"."beer_id" = ?  [["beer_id", 1]]
=> #<ActiveRecord::Associations::CollectionProxy [#<Rating id: 1, score: 10, beer_id: 1, created_at: "2014-01-15 22:34:48", updated_at: "2014-01-15 22:34:48">, #<Rating id: 2, score: 21, beer_id: 1, created_at: "2014-01-15 22:34:50", updated_at: "2014-01-15 22:34:50">, #<Rating id: 3, score: 17, beer_id: 1, created_at: "2014-01-15 22:34:53", updated_at: "2014-01-15 22:34:53">]>
irb(main):006:0> 
```

Reittaukset siis lisätään ensimmäisenä kannasta löytyvälle oluelle. Huomaa luontitapa, saman asian olisi ajanut monimutkaisempi tapa
  
```ruby
    b.ratings << Rating.create score:15     
```

>## Tehtävä 1
>
>Konsolin käyttörutiini on Rails-kehittäjälle äärimmäisen tärkeää. Tee seuraavat asiat konsolista käsin:
>
>luo uusi panimo "BrewDog", perustamisvuosi 2007<br/>
>lisää panimolle kaksi olutta
>* Punk IPA (tyyli IPA)
>* Nanny State (tyyli lowalcohol)
>lisää molemmille oluille muutama reittaus
>
>Kertaa tarvittaessa edellisen viikon [materiaalista](https://github.com/mluukkai/WebPalvelinohjelmointi2014/blob/master/web/viikko1.md) konsolia käsittelevät osuudet.
>
>palauta tämä tehtävä lisäämällä sovelluksellesi hakemisto exercises ja sinne tiedosto exercise1, joka sisältää copypasten konsolisessiosta 

Nyt tietokannassamme on reittauksia, ja haluamme saada ne listattua kaikkien reittausten sivulle.

> ## Tehtävä 2
>
> Listataan kaikki reittaukset ratings-sivulla. Ota mallia esim. panimon <code>index</code>-metodista ja sitä vastaavasta templatesta. Tee reittauksen lista ensin esim. seuraavaan tyyliin
>
>```erb
><ul>
>  <% @ratings.each do |rating| %>
>    <li> <%= rating %> </li>
>  <% end %> 
></ul>
>```
>
> Lisää sivulle myös tieto reittausten yhteenlasketusta lukumäärästä

Tässä vaiheessa sivun pitäisi näyttää suunilleen seuraavalta

![kuva](https://github.com/mluukkai/WebPalvelinohjelmointi2014/raw/master/images/ratebeer-w2-1.png)

Reittaus renderöityy hiukan ikävässä muodossa. Tämä johtuu siitä, että li-elementin sisällä on pelkkä olion nimi, ja koska emme ole määritelleet Ratingille olion merkkijonomuotoa määrittelevää <code>to_s</code>-metodia, käytössä on kaikkien luokkien yliluokalta Objectilta peritty oletusarvoinen <code>to_s</code>.

> ## Tehtävä 3
>
> Tee sitten luokalle Rating metodi <code>to_s</code>, joka palauttaa oliosta paremman merkkijonoesityksen, esim. muodossa "karhu 35", eli ensin reitatun oluen nimi ja sen jälkeen reittauksen pistemäärä.
>
> Merkkijonon muodostamisessa seuraavasta voi olla apua https://github.com/mluukkai/WebPalvelinohjelmointi2014/blob/master/web/rubyn_perusteita.md#merkkijonot

Tehtävän jälkeen reittausten sivujen tulisi näyttää suunilleen seuraavalta:

![kuva](https://github.com/mluukkai/WebPalvelinohjelmointi2014/raw/master/images/ratebeer-w2-2.png)

Huom: kun kirjoitat sovelluksellesi uutta koodia, useimmiten on järkevämpää tehdä kokeiluja konsolista käsin. Seuraavassa kokeillaan reittauksen oletusarvoista <code>to_s</code>-metodin palauttamaa arvoa:

```ruby
irb(main):024:0> r = Rating.last
irb(main):025:0> r.to_s
=> "#<Rating:0x007f8054b1cb10>"
irb(main):026:0>  
```

Määritellään reittaukselle <code>to_s</code>-metodi:

```ruby
class Rating < ActiveRecord::Base
  belongs_to :beer

  def to_s
    "tekstiesitys"
  end
end
```

ja kokeillaan uudelleen konsolista:

```ruby
irb(main):026:0> r.to_s
=> "#<Rating:0x007f8054b1cb10>"
```

Muutos ei kuitenkaan vaikuta tulleen voimaan, missä vika? 

Jotta muutettu koodi tulisi voimaan, on uusi koodi ladattava konsolin käyttöön komennolla <code>reload!</code> ja käytettävä uudestaan kannasta haettua olioa:

```ruby
irb(main):027:0> reload!
Reloading...
=> true
irb(main):028:0> r.to_s
=> "#<Rating:0x007f8054b1cb10>"
irb(main):029:0> r = Rating.last
irb(main):030:0> r.to_s
=> "tekstiesitys"
irb(main):031:0> 
```

Eli kuten yllä näemme, ei pelkkä koodin uudelleenlataaminen vielä riitä, sillä muuttujassa <code>r</code> olevassa oliossa on käytössä edelleen vanha koodi. 

> ## Tehtävä 4 
>
> Lisää luokalle <code>Beer</code> metodi <code>average_rating</code>, joka laskee oluen ratingien keskiarvon. Lisää keskiarvo oluen sivulle __jos__ oluella on ratingeja
>
> Näkymätemplatessa voi tehdä tuotettavasta sisällöstä ehdollisen seuraavasti
>
>```erb
><% if @beer.ratings.empty? %>
>  beer has not yet been rated!
><% else %>
>  beer has some ratings
><% end %>
>```

Tehtävän jälkeen oluen sivun tulisi näyttää suunilleen seuraavalta (huom: edellisen viikon jäljiltä sivullasi saattaa näkyä panimon nimen sijaan panimon id. Jos näin on, muuta näkymäsi vastaamaan kuvaa):

![kuva](https://github.com/mluukkai/WebPalvelinohjelmointi2014/raw/master/images/ratebeer-w2-3.png)

> ## Tehtävä 5
>
> Moduuli enumerable (ks. http://ruby-doc.org/core-2.0.0/Enumerable.html) sisältää runsaasti oliokokoelmien läpikäyntiin tarkoitettuja apumetodeja. 
>
> Oliokokoelmamaiset luokat voivat sisällyttää moduulin enumerable toiminnallisuuden itselleen, ja tällöin ne perivät moduulin tarjoaman toiminnallisuuden. 
>
> Tutustu nyt <code>inject</code>-metodiin (ks. esim. http://blog.jayfields.com/2008/03/ruby-inject.html ja etsi goolella lisää ohjeita) ja muuta (tarvittaessa) oluen reittausten keskiarvon laskeva metodi käyttämään injectiä
>
> Keskiarvon laskeminen onnistuu tässä tapauksessa myös helpommin hyödyntämällä ActiceRecordin metodeja, ks. http://guides.rubyonrails.org/active_record_querying.html#calculations

Lisätään konsolista jollekin vielä reittaamattomalle oluelle yksi reittaus. Oluen sivu näyttää nyt seuraavalta:

![kuva](https://github.com/mluukkai/WebPalvelinohjelmointi2014/raw/master/images/ratebeer-w2-4.png)

Sivulla on pieni, mutta ikävä kielioppivirhe:

    beer has 1 ratings

> ## Tehtävä 6
>
> Tutustu Railsissa valmiina olevaan <code>pluralize</code>-apumetodiin http://apidock.com/rails/ActionView/Helpers/TextHelper/pluralize ja tee oluen sivusta metodin avulla kieliopillisesti oikeaoppinen (eli yhden reittauksien tapauksessa tulee tulostua 'beer has 1 rating')

## Lomake ja post

Tehdään nyt sovellukseen mahdollisuus reittausten luomiseen www-sivulta käsin.

Railsin konventioiden mukaan Rating-olion luontiin tarkoitetun lomakkeen tulee löytyä osoitteesta ratings/new, ja lomakkeeseen pääsyn hoitaa ratings-kontrollerin metodi <code>new</code>.

Luodaan vastaava reitti routes.rb:hen

    get 'ratings/new', to:'ratings#new'

Lisäämme siis ratings-kontrolleriin (joka siis täydelliseltä nimeltään on RatingsController) metodin <code>new</code>, joka huolehtii lomakkeen renderöinnistä. Metodi on yksinkertainen:

```ruby
  def new
    @rating = Rating.new
  end
```

Metodi ainoastaan luo uuden Rating-olion ja välittää sen <code>@rating</code>-muuttujan avulla oletusarvoisesti renderöitävälle näkymätemplatelle new.html.erb. 

Luodaan nyt seuraava näkymä eli tiedosto /app/views/ratings/new.html.erb:

```erb
<h2>Create new rating</h2>

<%= form_for(@rating) do |f| %>
  beer id: <%= f.number_field :beer_id %>
  score: <%= f.number_field :score %>
  <%= f.submit %>
<% end %>
```

Mene nyt lomakkeen sisältävälle sivulle eli osoitteeseen http://localhost:3000/ratings/new

Näkymän avulla muodostuva hHTML-koodi näyttää (suunilleen) seuraavalta (näet koodin menemällä sivulle ja valitsemalla selaimesta _view page source_):

```erb
<form action="/ratings" method="post">
  beer id: <input name="rating[beer_id]" type="number" />
  score: <input name="rating[score]" type="number" />
  <input name="commit" type="submit" value="Create Rating" />
</form>
```

eli generoituu normaali HTML-lomake (ks. tarkemmin http://www.w3.org/community/webed/wiki/HTML/Training#Forms). 

Lomakkeen lähetystapahtuman kohdeosoite on /ratings ja käytettävä HTTP-metodi GET:in sijasta POST. Lomakkeessa on kaksi numeromuotoista kenttää ja niiden arvot lähetetään vastaanttajalle POST-kutsun mukana muuttujien <code>rating[beer_id]</code> ja <code>rating[score]</code> arvoina.

Railsin metodi <code>form_for</code> siis muodostaa automaattisesti oikeaan osoitteeseen lähetettävän, oikeanlaisen formin, jossa on syöttökentät kaikille parametrina olevan tyyppisen olion attribuuteille.

Lisää lomakkeiden muodostamisesta <code>form_for</code>-metodilla osoitteessa
 http://guides.rubyonrails.org/form_helpers.html#dealing-with-model-objects

Jos yritämme luoda reittauksen aiheutuu virheilmoitus <code>No route matches [POST] "/ratings"</code> eli joudumme luomaan tiedostoon config/routes.rb reitin: 

    post 'ratings', to: 'ratings#create'

Uuden olion luonnista vastaava metodi on Railsin konvention mukaan nimeltään <code>create</code>, luodaan sen pohja:

```ruby
  def create
    raise 
  end
```

Tässä vaiheessa metodi ei tee muuta kuin aiheuttaa poikkeuksen (metodikutsu <code>raise</code>). 

Kokeillaan nyt lähettää lomakkeella tietoa. Kontrollerin metodissa heittämä poikkeus aiheuttaa virheilmoituksen. Rails lisää virhesivulle erilaista diagnostiikkaa, mm. HTTP-pyynnön parametrit sisältävän hashin, joka näyttää seuraavalta:

```ruby
{"utf8"=>"✓",
 "authenticity_token"=>"1OfMRb9BTZzTnM5PfpFUupImkdIbLbwWi0FB90XBSqs=",
 "rating"=>{"beer_id"=>"1", "score"=>"2"},
 "commit"=>"Create Rating"}
```

Hashin sisällä on siis välittynyt lomakkeen avulla lähetetty tieto. 

Parametrit sisältävä hash on kontrollerin sisällä talletettu muuttujaan <code>params</code>. 
Uuden ratingin tiedot ovat hashissa avaimen <code>:rating</code> arvona, eli pääsemme niihin käsiksi komennolla <code>params[:rating]</code> joka taas on hash jonka arvo on <code>{"beer_id"=>"1", "score"=>"2"}</code>. Eli esim. pistemäärään päästäisiin käsiksi komennolla <code>params[:rating][:score]</code>.

## Debuggeri

Tutkitaan hieman asiaa kontrollerista käsin Railsin debuggeria.

Lisää tiedostoon Gemfile rivi:

    gem 'debugger', group: [:development, :test]

ja suorita komentoriviltä komento <code>bundle install</code>. Käynnistä nyt Rails-sovellus uudelleen, eli paina ctrl+c Railsia suorittavassa terminaalissa ja anna komento <code>rails s</code> uudelleen. Uudelleenkäynnistys on syytä suorittaa aina uusia gemejä asennettaessa.

Lisätään kontrollerin alkuun, eli sille kohtaan koodia jota haluamme tarkkailla, komento <code>debugger</code>

```ruby
  def create
    debugger
    raise 
  end
```

Kun luot lomakkeella uuden reittauksen, sovellus pysähtyy komennon <code>debugger</code> kohdalle. Terminaaliin josta Rails on käynnistetty, avautuu nyt interaktiivinen konsolinäkymä:

```ruby
[7, 16] in /Users/mluukkai/kurssirepot/wadror/ratebeer/app/controllers/ratings_controller.rb
   7      @rating = Rating.new
   8    end
   9  
   10    def create
   11      debugger
=> 12      raise
   13    end
   14  end
(rdb:1) 
```

Nuoli kertoo seuraavana vuorossa olevan komennon. Tutkitaan nyt <code>params</code>-muuttujan sisältöä:

```ruby
(rdb:1) params
{"utf8"=>"✓", "authenticity_token"=>"hZaC8o95xUbekA3PTsVZ+JmkVj9CCn5a4Kw8tF96WOU=", "rating"=>{"beer_id"=>"2", "score"=>"10"}, "commit"=>"Create Rating", "action"=>"create", "controller"=>"ratings"}
(rdb:1) params[:rating]
{"beer_id"=>"2", "score"=>"10"}
(rdb:1) params[:rating][:score]
"10"
(rdb:1) 
```

Debuggerin konsolissa voi tarpeen vaatiessa suorittaa mitä tahansa koodia Rails-konsolin tavoin.

Debuggerin tärkeimmät komennot lienevät step, next, continue ja help. Step suorittaa koodista seuraavan askeleen, edeten mahdollisiin metodikutsuihin. Next suorittaa seuraavan rivin kokonaisuudessaan. Continue jatkaa ohjelman suorittamista normaaliin tapaan.

Lisätietoa debuggerista seuraavassa
http://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debugger-gem. 

## Reittauksen talletus

Kontrollerin sisällä <code>params[:rating]</code> siis sisältää kaiken tiedon, joka uuden reittauksen luomiseen tarvitaan. Ja koska kyseessä on hash joka on muotoa <code>{"beer_id"=>"1", "score"=>"30"}</code>, voi sen antaa suoraan metodin <code>create</code> parametriksi, eli reittauksen luonnin pitäisi periaatteessa onnistua komennolla:

    Rating.create params[:rating]  # joka siis tarkoittaa samaa kuin Rating.create beer_id:"1", score:"30"

Muuta siis kontrollerisi koodi seuraavanlaiseksi:

```ruby
  def create
    Rating.create params[:rating]
  end
```

Kokeile nyt luoda reittaus. Vastoin kaikkia odotuksia, luomisoperaatio epäonnistuu ja seurauksena on virheilmoitus

	ActiveModel::ForbiddenAttributesError

Mistä on kyse? 


Jos olisimme tehneet reittauksen luovan komennon muodossa

	Rating.create beer_id:params[:rating][:beer_id], score:params[:rating][:score]

joka siis periaattessa tarkoittaa täysin samaa kuin ylläoleva muoto (sillä <code>params[:rating]</code> on sisällöltän __täysin sama__ hash kuin <code>beer_id:params[:rating][:beer_id], score:params[:rating][:score]</code>), ei virheilmoitusta olisi tullut. [Tietoturvasyistä](http://en.wikipedia.org/wiki/Mass_assignment_vulnerability) Rails ei kuitenkaan salli mielivaltaista <code>params</code>-muuttujasta tapahtuvaa "massasijoitusta" (engl. mass assignment eli kaikkien parametrien antamista hashina) olion luomisen yhteydessä. 

Rails 4:stä lähtien kontrollerin on lueteltava eksplisiittisesti mitä hashin <code>params</code> sisällöstä voidaan massasijoittaa olioiden luonnin yhteydessä. Tähän kontrolleri käyttää <code>params</code>:in metodeja <code>require</code> ja <code>permit</code>. 

Periaatteena on, että ensin requirella otetaan paramsin sisältä luotavan olion tiedot sisältävä hash:

	params.require(:rating)
   
tämän jälkeen luetellaan permitillä ne kentät, joiden arvon massasijoitus sallitaan:

	params.require(:rating).permit(:score, :beer_id)   
   
Kontrollerimme on siis seuraava:   
   

```ruby
  def create
    Rating.create params.require(:rating).permit(:score, :beer_id)
  end
```

Lisää tietoa lomakkeiden parametrien käsittelystä http://edgeguides.rubyonrails.org/action_controller_overview.html luvusta 4.5 Strong parameters

Kokeile nyt reittauksen luomista. HUOM: kun luot lomakkeella reittausta, tarkista, että lomakkeelle syöttämä oluen id vastaa jonkun tietokannassa olevan oluen id:tä! 

Reittausten luominen onnistuu jo (tarkista tilanne konsolista tai kaikkien reittausten sivulta), mutta aiheuttaa virheilmoituksen, sillä metodi yrittää renderöidä oletusarvoisesti näkymätemplaten /views/ratings/create.html.erb jota ei ole.

## Uudelleenohjaus

Voisimme luoda templaten, mutta päätämmekin, että uuden reittauksen luomisen jälkeen käyttäjän selain __uudelleenohjataan__ kaikki reittaukset sisältävälle sivulle, eli muutetaan kontrollerin koodi muodoon:

```ruby
  def create
    Rating.create params.require(:rating).permit(:score, :beer_id)
    redirect_to ratings_path
  end
```

<code>ratings_path</code> on railsin tarjoama polkuapumetodi, joka tarkoittaa samaa kuin "/ratings"

Jos olet luonut reittauksia joihin liittyvä <code>beer_id</code> ei vastaa olemassaolevan oluen id:tä, saat nyt todennäköisesti virheilmoituksen. Voit tuhota konsolista (<code>rails console</code>) käsin nämä ratingit seuraavasti

```ruby
    Rating.last        # näyttää viimeksi luodun ratingin, tarkasta onko siinä oleva beer_id virheellinen
    Rating.last.delete # poistaa viimeksi luodun ratingin
```

Saat tuhottua oluettomat ratingit myös seuraavalla "onelinerilla":

```ruby
    Rating.all.select{ |r| r.beer.nil? }.each{ |r| r.delete }
```

Select luo taulukon, johon sisältyy ne läpikäydyn kokoelman alkiot, joille koodilohkossa oleva ehto on tosi. <code>r.beer.nil?</code> palauttaa <code>true</code> jos olio <code>r.beer</code> on <code>nil</code>.

Mitä kontrollerissa käytetty komento <code>redirect_to ratings_path</code> oikeastaan tekee? Normaalistihan kontrolleri renderöi sopivan näkymätemplaten ja näin aikaansaatu HTML-koodi palautetaan selaimelle, joka renderöi sivun näytölle.

Uudelleenohjausessa palvelin lähettää selaimelle statuskoodilla 302 varustetun vastauksen, joka ei sisällä ollenkaan HTML:ää. Vastaus sisältää ainoastaan osoitteen, mihin selaimen tulee automaattisesti tehdä HTTP GET -pyyntö. Uudelleenohjautuminen on huomaamatonta selaimen käyttäjän kannalta. 

Kokeile mitä tapahtuu kun laitat uuden reittauksen luomisen jälkeiseksi uudelleenohjaukseksi esim. <code>redirect_to "http://www.cs.helsinki.fi"</code>!

## redirect_to vs render

http://en.wikipedia.org/wiki/Post/Redirect/Get

Olisi ollut teknisesti mahdollista olla käyttämättä uudelleenohjausta ja renderöidä kaikkien reittausten sivu suoraan uuden reittauksen luovasta kontrollerista:

```ruby
  def create
    Rating.create params.require(:rating).permit(:score, :beer_id)
    @ratings = Rating.all
    render :index
  end
```

Vaikka aikaansaannos näyttää sivuston käyttäjälle täsmälleen samalta, tämä ei ole kuitenkaan järkevää muutamastakaan syystä. Ensinnäkin kaikki metodissa <code>index</code> oleva koodi, joka tarvitaan näkymän muodostamiseen on kopioitava <code>create</code>-metodiin. Toinen syy liittyy selaimen käyttäytymiseen. Jos kontorollerimme käyttäisi sivun renderöintiä ja selaimen käyttäjä refreshaisi sivun uuden oluen luomisen jälkeen, kävisi seuraavasti:

![kuva](https://github.com/mluukkai/WebPalvelinohjelmointi2014/raw/master/images/ratebeer-w2-5.png)

eli selain kysyy käyttäjältä lähetetäänkö lomakkeen tiedot uudelleen sillä edellinen selaimen toiminto jonka refreshaus suorittaa on nimenomaan lomakkeen tietojen lähetyksen hoitanut HTTP POST.
Redirectauksen yhteydessä vastaavaa ongelmaa ei ole, sillä POST-komennon jälkeen seuraava käyttäjälle näkyvä sivu saadaan aikaan redirectauksen aikaansaamalla HTTP GET:illä.

Nyrkkisääntönä (ei vaan Railsissa vaan Web-ohjelmoinnissa yleensäkin, ks. http://en.wikipedia.org/wiki/Post/Redirect/Get) onkin käyttää lomakkeista huolehtivien HTTP POST -metodien käsittelevässä kontrollerissa aina uudelleenohjausta (ellei kontrollerin suorittama operaatio epäonnistu esim. lomakkeella lähetetyn tiedon virheellisyyden vuoksi).

Nostetaan vielä esiin tämä tärkeä ero:
* kun kontrollerimetodi päätty komentoon <code>render :jotain</code> (joka siis tapahtuu usein implisiittisesti) generoi Rails-sovellus HTML-sivun jonka palvelin lähettää selaimelle renderöitäväksi
* kun kontrollerimetodi päättyy komentoon <code>redirect_to osoite</code> lähettää palvelin selaimelle statuskoodissa 302 varustetun uudelleenohjauspyynnön, jossa se pyytää selainta tekemään automaattisesti HTTP GET -pyynnön kontrollerimetodin määrittelemään osoitteeseen, selaimen käyttäjän kannalta uudelleenohjaus on huomaamaton toimenpide

**Jokaisen** Web-ohjelmoijan on syytä ymmärtää edellinen!

## Polkuapumetodit

Rails luo automaattisesti kaikille routes.rb:hen määriteillyille reiteille ns. polkumetodit (engl. path helper), joita hyödyntämällä sovelluksessa ei ole tarvetta kovakoodata eri sivujen osoitteita.

Esim. uuden reittauksen jälkeisen uudelleenohjauksen osoite olisi voitu <code>ratings_path</code>-apufunktion sijaan kovakoodata:

```ruby
  def create
    Rating.create params[:rating]
    redirect_to 'ratings'
  end
```

Kuten ei yleensäkään, ei kovakoodaus ole järkevää osoitteidenkaan suhteen.

Tarjolla olevia automaattisesti generoituja polkuja pääsee tarkastelemaan komentoriviltä komennolla <code>rake routes</code>

```ruby
mluukkai@e42-17:~/WadRoR/ratebeer$ rake routes
       beers GET    /beers(.:format)              beers#index
             POST   /beers(.:format)              beers#create
    new_beer GET    /beers/new(.:format)          beers#new
   edit_beer GET    /beers/:id/edit(.:format)     beers#edit
        beer GET    /beers/:id(.:format)          beers#show
             PUT    /beers/:id(.:format)          beers#update
             DELETE /beers/:id(.:format)          beers#destroy
   breweries GET    /breweries(.:format)          breweries#index
             POST   /breweries(.:format)          breweries#create
 new_brewery GET    /breweries/new(.:format)      breweries#new
edit_brewery GET    /breweries/:id/edit(.:format) breweries#edit
     brewery GET    /breweries/:id(.:format)      breweries#show
             PUT    /breweries/:id(.:format)      breweries#update
             DELETE /breweries/:id(.:format)      breweries#destroy
        root        /                             breweries#index
     ratings GET    /ratings(.:format)            ratings#index
 ratings_new GET    /ratings/new(.:format)        ratings#new
             POST   /ratings(.:format)            ratings#create
```

Esim alimmat 3 reittiä kertovat seuraavaa:
* metodikutsu <code>ratings_path</code> generoi linkin, joka vie osoitteeseen "ratings" ja ohjautuu ratings-kontrollerin metodille <code>index</code>.
* metodikutsu <code>ratings_new_path</code> generoi linkin, joka vie osoitteeseen "ratings/new" ja ohjautuu ratings-kontrollerin metodille <code>new</code>. Tämä taas renderöi reittauksentekoformin
** huom. kuten ylempänä olevia reittejä vertailemalla huomaamme, ei <code>ratings_new_path</code> ole samanlainen kuin esim uusien oluiden luontipolku, asia korjataan myöhemmin
* POST-kutsu osoitteeseen "ratings" ohjataan ratings-kontrollerin metodille <code>create</code>

Kuten olemme jo huomaneet Rails 4:ssä komennon <code>rake routes</code> informaatio tulee myös virhetilanteissa renderöityvälle web-sivulle. Sivu jopa tarjoaa interaktiivisen työkalun, jonka avulla voi kokeilla miten sovellus reitittää syötetyn esimerkkipolun:

![kuva](https://github.com/mluukkai/WebPalvelinohjelmointi2014/raw/master/images/ratebeer-w2-6.png)


> ## Tehtävä 7
>
> Lisää kaikkien reittausten sivulle linkki uuden reittauksen tekemiseen. Lisää sovelluksen navigointipalkkiin linkki kaikkien reittausten listalle

## Oluiden valinta listalta

Uuden reittauksen luominen on nyt hieman ikävää, sillä reittaajan pitää tietää oluen id. Muutetaan reittaamista siten, että käyttäjä voi valita reitattavan oluen listalta.

Jotta uuden reittauksen luontilomake pystyisi muodostamaan listan, on lomakkeen näyttämisestä huolehtivan kontrollerin haettava lista kannasta ja talletettava se muuttujaan, eli laajennetaan kontrolleria seuraavasti:

```ruby
class RatingsController < ApplicationController
  def new
    @rating = Rating.new
    @beers = Beer.all
  end

  # ...
end
```

Sivua http://guides.rubyonrails.org/form_helpers.html#making-select-boxes-with-ease konsultoimalla ja hieman kokeiluja tekemällä päädytään siihen että reittauksen luovaa lomaketta tulee muuttaa seuraavasti:

```erb
<%= form_for(@rating) do |f| %>
  <%= f.select :beer_id, options_from_collection_for_select(@beers, :id, :name) %>
  score: <%= f.number_field :score %>

  <%= f.submit %>
<% end %>
```

eli lomakkeen <code>beer_id</code>:n arvo generoidaan HTML lomakkeen select-elementillä, jonka valintavaihtoehdot muodostetaan  metodilla <code>options_from_collection_for_select</code> <code>@beers</code>-muuttujassa olevasta oluiden listasta siten, että arvoksi otetaan oluen id ja lomakkeen käyttäjälle näytetään oluen nimi.

> ## Tehtävä 8
>
> Tee oluelle <code>to_s</code>-metodi, jonka muodostamassa tekstuaalisessa esityksessä on sekä oluen että sen panimon nimi
>
> Muuta reittauksen luovaa lomaketta siten, että valittavista oluista näytetään nimikentän arvon sijaan olion <code>to_s</code>-metodin palauttama tekstuaalinen esitys

> ## Tehtävä 9
>
> Tee vastaava muutos oluiden luomisesta huolehtivaan lomakkeeseen (tiedostossa views/beers/_form.html.erb) ja sen näyttämisestä vastaavaan kontrolleriin (beers#new), eli sen sijaan että luotavan oluen panimo määritellään antamalla id käsin, valitsee käyttäjä panimon listalta.
>
> Muuta uuden oluen luomisen hoitavaa kontrolleria (beers#create) siten, että uuden oluen luomisen jälkeen selain uudelleenohjataan kaikkien oluiden listan sisältävälle sivulle (jonka osoite kannattaa generoida polkuapumetodilla). Oletusarvoisesti uudelleenohjaus tapahtuu luodun oluen sivulle komennolla <code>redirect_to @beer</code>, eli muutos tulee tähän.
>
> Scaffoldingin automaattisesti luoma lomake sisältää mm. virheiden raportointiin tarkoitettua koodia johon tutustumme tarkemmin myöhemmin. 

> ## Tehtävä 10
> 
> Tällä hetkellä luotavan oluen tyyli annetaan merkkijonona. Tulemme myöhemmin muokkaamaan sovellusta siten, että myös oluttyylit talletetaan tietokantaan. 
>
> Tehdään ensin välivaiheen ratkaisu, eli muuta sovellustasi siten, että luotavan oluen tyyli valitaan listalta, joka muodostetaan kontrollerin välittämän taulukon perusteella. Olutkontrollerin <code>new</code>-metodin koodi muuttuu siis seuraavasti:
>
> Kontrolleri
>```ruby
>  def new
>    @beer = Beer.new
>    @breweries = Brewery.all
>    @styles = ["Weizen", "Lager", "Pale ale", "IPA", "Porter"]
>  end
>```
>
> Näkymän tulee siis generoida lomakkeeseen valintavaihtoehdot taulukon <code>@styles</code> perusteella. Vaihtoehtojen generointiin kannattaa nyt metodin <code>options_from_collection_for_select</code> sijaan käyttää metodia <code>options_for_select</code>, ks. 
> http://api.rubyonrails.org/classes/ActionView/Helpers/FormOptionsHelper.html#method-i-options_for_select 

## nilin etsintää

On enemmän kuin todennäköistä että törmäät jossain vaiheessa seuraavan tyyliseen (jo viime viikolla mainittuun) ongelmaan:

![kuva](https://github.com/mluukkai/WebPalvelinohjelmointi2014/raw/master/images/ratebeer-w2-7.png)

nyt rivi 

	<%= link_to beer.brewery.name, beer.brewery %>
	
on aiheuttanut virheen 
    
    undefined method `name' for nil:NilClass

käytännössä tämä siis tarkoittaa, että rivillä on yritetty kutsua arvolle <code>nil</code> metodia <code>name</code>.  Nyt syyllinen on ilmiselvästi <code>beer.brewery.name</code>, eli näyttää siltä että jonkun oluen panimona on <code>nil</code>. Tämä voi johtua joko siitä että oluen <code>brewery_id</code> on <code>nil</code> tai <code>brewery_id</code>:n arvona on virheellinen (esim poistetun panimon) id.

Virheen syytä kannattaa etsiä konsolista:

```ruby
irb(main):008:0> Beer.where(brewery_id:nil)
  Beer Load (0.2ms)  SELECT "beers".* FROM "beers" WHERE "beers"."brewery_id" IS NULL
=> #<ActiveRecord::Relation [#<Beer id: 13, name: "Hardcore IPA", style: "IPA", brewery_id: nil, created_at: "2014-01-16 16:58:56", updated_at: "2014-01-16 16:59:45">]>
irb(main):009:0> 
```

Syyllinen löytyy nyt erittäin helposti ja ongelma saadaan korjattua. Jos kyseessä olisi ollut virheellinen id, ei syyllisen etsiminen ole aivan yhtä suoraviivaista. Se onnistuu esim. seuraavasti:


```ruby
irb(main):015:0> Beer.all.select{ |b| b.brewery==nil }
=> [#<Beer id: 13, name: "Hardcore IPA", style: "IPA", brewery_id: 99, created_at: "2014-01-16 16:58:56", updated_at: "2014-01-16 17:30:08">]
irb(main):016:0> 
```

Eli rajoitutaan komennolla <code>select</code> oluiden joukosta siihen, johon liittyvä panimo on <code>nil</code>. Nimittäin jos oluella on virheellinen panimoviiteavain, on tästä seurauksena se, että oluen panimo on <code>nil</code>.


##  REST ja reititys

REST (representational state transfer) on HTTP-protokollaan perustuva arkkitehtuurimalli erityisesti web-pohjaisten sovellusten toteuttamiseen. Taustaidea on periaatteessa yksinkertainen: osoitteilla määritellään haettavat ja muokattavat resurssit, pyyntömetodit kuvaavat resurssiin kohdistuvaa operaatiota, ja pyynnön rungossa on tarvittaessa resurssiin liittyvää dataa. 

Lue nyt http://guides.rubyonrails.org/routing.html kohtaan 2.5 asti. Rails siis tekee helpoksi REST-tyylisen rakenteen noudattamisen.
Jos kiinnostaa, RESTistä voi lukea lisää esim.
[täältä](http://www.ibm.com/developerworks/webservices/library/ws-restful/)

Muutetaan reittauksen polut tiedostoon routes.rb siten, että käytetään valmista <code>resources</code>-määrittelyä:

```ruby
  # kommentoi tai poista entiset määrittelyt
  #get 'ratings', :to => 'ratings#index'
  #get 'ratings/new', :to => 'ratings#new'
  #post 'ratings', :to => 'ratings#create'

  resources :ratings, :only => [:index, :new, :create]
```

Koska emme tarvitse reittejä **delete**, **edit** ja **update**, käytämme <code>:only</code>-tarkennetta, jolla valitsemme vain tarvitsemamme reitit. Katsotaan nyt komentoriviltä <code>rake routes</code> -komennolla (tai virheellisen urlin omaavalta web-sivulta) sovellukseen määriteltyjä polkuja:

```ruby
     ratings GET    /ratings(.:format)            ratings#index
             POST   /ratings(.:format)            ratings#create
  new_rating GET    /ratings/new(.:format)        ratings#new
```

Tulos on muuten sama kuin edellä, mutta apumetodin <code>ratings_new_path</code> nimi on nyt Railsin konvention mukainen <code>new_rating_path</code>. 

Korvaa vielä templatessa app/views/ratings/index.erb.html käytetty vanha polkumetodikutsu uudella.

## Ratingin poisto

Lisätään ohjelmaan vielä mahdollisuus poistaa reittauksia. Lisätään ensin vastaava reitti muokkaamalla routes.rb:tä:

    resources :ratings, :only => [:index, :new, :create, :destroy]

Lisätään sitten reittauksien listalle linkki, jonka avulla kunkin reittauksen voi poistaa:

```erb
<ul>
  <% @ratings.each do |rating| %>
    <li> <%= rating %> <%= link_to 'delete', rating_path(rating.id), :method => :delete %> </li>
  <% end %>
</ul>
```

Railsin käyttämän konvention mukaan olion tuhoaminen tehdään HTTP:n DELETE-metodilla. Jos tuhottavana on rating ,jonka id on 5, tapahtuu nyt linkkiä klikkaamalla HTLLP DELETE -kutsu osoitteeseen ratings/5. 

Kuten jo aiemmin mainittiin, voi <code>rating_path(rating.id)</code>-kutsun sijaan <code>link_to</code>:n parametrina olla suoraan olio, jolle kutsu kohdistuu, eli edellinen hieman lyhemmässä muodossa:

```erb
<ul>
  <% @ratings.each do |rating| %>
    <li> <%= rating %> <%= link_to 'delete', rating, :method => :delete %> </li>
  <% end %>
</ul>
```

Jotta saamme poiston toimimaan, tulee vielä määritellä kontrollerille poiston suorittava metodi <code>destroy</code>.

Metodiin johtava url on muotoa ratings/[tuohottavan olion id]. metodi pääsee Railsin konvention mukaan käsiksi tuhottavan olion id:hen <code>params</code>-olion kautta. Tuhoaminen tapahtuu hakemalla olio tietokannasta ja kutsumalla sen metodia <code>delete</code>:

```ruby
  def destroy
    rating = Rating.find(params[:id])
    rating.delete
    redirect_to ratings_path
  end
```

Lopussa suoritetaan uudelleenohjaus takaisin kaikkien reittausten sivulle. Uudelleenohjaus siis aiheuttaa sen, että selain lähettää sovellukselle uudelleen GET-pyynnön osoitteeseen /ratings, ja ratings#index-metodi suoritetaan tämän takia uudelleen.

> ## Tehtävä 11
>
> Reittauksen poisto on nyt siinä mielessä ikävä, että herkkäsorminen sivuston käyttäjä saattaa vahinkoklikkauksella tuhota reittauksia.
> 
> Katso esim. kaikki oluet listaavan sivun templatesta /app/views/beers/index.html.erb mallia ja tee ratingin tuhoamisesta sellainen, että käyttäjältä kysytään varmistus reittauksen tuhoamisen yhteydessä.

## Orvot oliot

Jos sovelluksesta poistetaan olut, jolla on reittauksia, käy niin että poistettuun olueeseen liittyvät reittaukset jäävät tietokantaan, todennäköisesti tämä aiheuttaa virheen reittausten sivun renderöinnissä.

> ## Tehtävä 12
>
> Poista jokin olut, jolla on reittauksia ja mene reittausten sivulle. Seurauksena on virheilmoitus <code>undefined method `name' for nil:NilClass</code>
>
> Virhe taas aiheutuu siitä, että reittaus-olion <code>to_s</code>-metodissa kutsutaan <code>beer.name</code>
>
> Poista orvoksi jääneet reittaukset konsolista käsin. Yritä keksiä ensin itse komento/komennot, joiden avulla saat muodostettua orpojen reittauksen listan. Jos et keksi vastausta, hieman ylempänä tällä sivulla on tehtävään valmis vastaus. 

Olueeseen liittyvät reittaukset saadaan helposti poistettua automaattisesti. Merkitään oluen modelin koodiin <code>has_many :ratings</code> yhteyteen että reittaukset ovat oluesta riippuvaisia, ja että ne tuhotaan oluen tuhoutuessa:

```ruby
class Beer < ActiveRecord::Base
  belongs_to :brewery
  has_many :ratings, :dependent => :destroy

  # ...
end
```

Nyt orpojen ongelma poistuu. 


> ## Tehtävä 13
>
> Tee vastaava muutos panimoihin, eli kun panimo poistetaan, tulee panimoon liittuv ien oluiden poistua. 
>
> Tee panimo jolla on vähintään yksi olut jolla on reittauksia. Poista panimo ja varmista, että panimoon liittyvät oluet ja niihin liittyvät reittaukset poistuvat.



## Olioiden epäsuora yhteys

Sovelluksessamme panimoon liittyy oluita ja oluisiin liittyy reittauksia. Kuhunkin panimoon siis liittyy epäsuorasti joukko reittauksia. Rails tarjoaa helpon keinon päästä panimoista suoraan käsiksi reittauksiin:

```ruby
class Brewery < ActiveRecord::Base
  has_many :beers
  has_many :ratings, :through => :beers
end
```

eli yhteys määritellään kuten "tietokantatasolla" oleva yhteys, mutta yhteyteen lisätään tarkenne, että se muodostuu toisten oluiden kautta. Nyt panimoilla on reittaukset palauttava metodi <code>ratings</code>

Lisää yhteys koodiisi ja kokeile seuraavaa konsolista (muista ensin <code>reload!</code>):

```ruby
irb(main):005:0> k = Brewery.find_by name:"Koff"
irb(main):006:0> k.ratings
=> #<ActiveRecord::Associations::CollectionProxy [#<Rating id: 1, score: 10, beer_id: 1, created_at: "2014-01-15 22:34:48", updated_at: "2014-01-15 22:34:48">, #<Rating id: 2, score: 21, beer_id: 1, created_at: "2014-01-15 22:34:50", updated_at: "2014-01-15 22:34:50">, #<Rating id: 3, score: 17, beer_id: 1, created_at: "2014-01-15 22:34:53", updated_at: "2014-01-15 22:34:53">, #<Rating id: 10, score: 20, beer_id: 1, created_at: "2014-01-16 14:46:13", updated_at: "2014-01-16 14:46:13">, #<Rating id: 13, score: 12, beer_id: 3, created_at: "2014-01-16 15:13:09", updated_at: "2014-01-16 15:13:09">]>
irb(main):007:0> 

```

> ## Tehtävä 14
>
> Lisää yksittäisen panimon tiedot näyttävälle sivulle tieto panimon oluiden reittausten määrästä sekä keskiarvosta. Lisää tätä varten panimolle metodi <code>average_rating</code> reittausten keskiarvon laskemista varten.
>
> Tee reittausten yhteenlasketun määrän "kieliopillisesti moitteeton" 
tehtävän 6 tyyliin. Jos reittauksia ei ole, älä näytä keskiarvoa.

Panimon sivun tulisi näyttää muutoksen jälkeen suunilleen seuraavalta (Kuvassa oluiden lista on muutettu ul-elementin avulla toteutetuksi bulletlistaksi, sivulta on myös poistettu scaffoldingin luoma 'back'-linkki. Voit halutessasi tehdä muutoset myös omaan koodiisi):

![kuva](https://github.com/mluukkai/WebPalvelinohjelmointi2014/raw/master/images/ratebeer-w2-8.png)

Huomaamme, että oluella ja panimolla on täsmälleen samalla tavalla toimiva ja vieläpä saman niminen metodi <code>average_rating</code>. Ei ole hyväksyttävää jättää koodia tähän tilaan.

> ## Tehtävä 15
>
> Ruby tarjoaa keinon jakaa metodeja kahden luokan välillä moduulien avulla, ks. https://github.com/mluukkai/WebPalvelinohjelmointi2014/blob/master/web/rubyn_perusteita.md#moduuli
> 
> Moduleilla on useampia käyttötarkoituksia, niiden avulla voidaan mm. muodostaa nimiavaruuksia. Nyt olemme kuitenkin kiinnostuneita modulien avulla toteutettavasta _mixin_-perinnästä. 
>
> Tutustu nyt riittävällä tasolla moduleihin ja refaktoroi koodisi siten, että metodi <code>average_rating</code> siirretään moduuliin, jonka luokat <code>Beer</code> ja <code>Brewery</code> sisällyttävät. 
> * sijoita moduuli lib-kansioon
>* HUOM: lisää tiedostoon <code>config/application.rb</code> luokan <code>Application</code>määrittelyn  sisälle rivi <code>config.autoload_paths += Dir["#{Rails.root}/lib"]</code>, jotta Rails lataisi modulin koodin sovelluksen luokkien käyttöön. Rails server (ja konsoli) tulee käynnistää uudelleen lisäyksen jälkeen
> * HUOM2: jos muduulisi nimi on ao. esimerkin tapaan <code>RatingAverage</code> tulee se Rubyn nimentäkonvention takia sijaita tiedostossa <code>rating_average.rb</code>, eli vaikka luokkien nimet ovat Rubyssä isolla alkavia CamelCase-nimiä, noudattavat niiden tiedostojen nimet snake_case.rb-tyyliä.

Tehtävän jälkeen esim. luokan Brewery tulisi siis näyttää suunilleen seuraavalta (olettaen että tekemäsi moduulin nimi on RatingAverage):

```ruby
class Brewery < ActiveRecord::Base
  include RatingAverage

  has_many :beers
  has_many :ratings, :through => :beers
end
```

ja metodin <code>average_rating</code> tulisi edelleen toimia entiseen tyyliin:

```ruby
irb(main):001:0> b = Beer.first
irb(main):002:0> b.average_rating
=> #<BigDecimal:7fa4bbde7aa8,'0.17E2',9(45)>
irb(main):003:0> b = Brewery.first
irb(main):004:0> b.average_rating
=> #<BigDecimal:7fa4bfbf7410,'0.16E2',9(45)>
irb(main):005:0> 
```


## Yksinkertainen suojaus

Haluamme viikon lopuksi tehdä sovelluksesta sellaisen, että ainoastaan ylläpitäjä pystyy poistamaan painimoita. Toteutamme viikolla 3 kattavamman tavan autentikointiin, teemme nyt nopean ratkaisun [http basic -autentikaatiota](http://en.wikipedia.org/wiki/Basic_access_authentication)  hyödyntäen. Ks. http://api.rubyonrails.org/classes/ActionController/HttpAuthentication/Basic.html

Tutustumme samalla nopeasti Railsin kontrollerien _filtterimetodeihin_ ks. http://guides.rubyonrails.org/action_controller_overview.html#filters, joiden avulla voidaan helposti määritellä toiminnallisuutta, mikä suoritetaan esim. ennen (before_action) tietyn kontrollerin joidenkin metodien suorittamista.

Määrittelemme ensin panimokontrolleriin (<code>private</code>-näkyvyydellä varustetun) filtterimetodin nimeltään <code>authenticate</code>, joka suoritetaan ennen jokaista panimokontrollerin metodia:

```ruby
class BreweriesController < ApplicationController
  before_action :authenticate

  # ...

  private

  def authenticate
      raise "toteuta autentikointi"
  end
end
```

Filtterimetodi aiheuttaa poikkeuksen, joten mennessä minne tahansa panimoita käsitteleville sivuille aiheutuu poikkeus. Varmista tämä selaimella.

Rajoitetaan sitten filtterimetodin suoritus koskemaan ainoastaan panimon  poistoa:

```ruby
class BreweriesController < ApplicationController
  before_filter :authenticate, :only => [:destroy]

  # ...

  private

  def authenticate
      raise "toteuta autentikointi"
  end
end
```

Varmistetaan jälleen selaimella muut sivut toimivat, mutta panimon poisto aiheuttaa virheen.

Toteutetaan sitten http-basicauth-autentikointi (ks. tarvittaessa lisää esim. http://blog.dcxn.com/2011/09/30/the-simplest-possible-authentication-in-rails-http-auth-basic/)

Kovakoodataan käyttäjätunnukseksi "admin" ja salasanaksi "secret":

```ruby
class BreweriesController < ApplicationController
  before_filter :authenticate, :only => [:destroy]

  # ...

  private

  def authenticate
    authenticate_or_request_with_http_basic do |username, password|
      username == "admin" and password == "secret"
    end
  end
end
```

Ja sovellus toimii haluamallamme tavalla!

HUOM: kun olet kerran antanut oikean käyttäjätunnus-salasanaparin, ei selain kysy uusia tunnuksia mennessäsi sivulle uudelleen. Avaa uusi incognito-ikkuna jos haluat testata kirjautumista uudelleen!

Toimintaperiaatteena metodissa <code>authenticate_or_request_with_http_basic</code> on se, että sovellus pyytää selainta lähettämään käyttäjätunnuksen ja salasanan, jotka sitten välitetään <code>do</code>:n ja <code>end</code>:in välissä olevalle koodilohkolle parametrien <code>username</code> ja <code>password</code> avulla. Jos koodilohkon arvo on tosi, näytetään sivu käyttäjälle.

Http Basic -autentikaatio on kätevä tapa yksinkertaisiin sivujen suojaamistarpeisiin, mutta monimutkaisemmissa tilanteissa ja parempaa tietoturvaa edellytettäessä kannattaa käyttää muita ratkaisuja.

> ## Tehtävä 16
>
> Laajenna ratkaisua siten, että ohjelma hyväksyy myös muita kovakoodattuja käyttäjätunnus-salasana-pareja. Käytössä olevat tunnukset on kovakoodattu metodissa määriteltyyn hashiin. Metodin tulee toimia mielivaltaisen kokoisilla tunnukset sisältävillä hasheilla.
>
>```ruby
>   def authenticate
>    admin_accounts = { "admin" => "secret", "pekka" => "beer", "arto" => "foobar", "matti" => "ittam"}
>
>    authenticate_or_request_with_http_basic do |username, password|
>      # do something here
>    end
>  end
>```
>
> Testatessasi toiminnallisuutta, muista että joudut käyttämän incognito-selainta jos haluat kirjautua uudelleen annettuasi kertaalleen oikean käyttäjätunnus/salasanaparin.


## Tehtävien palautus

Commitoi kaikki tekemäsi muutokset ja pushaa koodi Githubiin. Deployaa myös uusin versio Herokuun.

Tehtävät kirjataan palautetuksi osoitteeseen http://wadrorstats2014.herokuapp.com/courses/1

Palautusten kirjaaminen onnistuu vasta maanantaina 20.1.
