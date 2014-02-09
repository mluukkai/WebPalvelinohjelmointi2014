Jatkamme sovelluksen rakentamista siitä, mihin jäimme viikon 4 lopussa. Allaoleva materiaali olettaa, että olet tehnyt kaikki edellisen viikon tehtävät. Jos et tehnyt kaikkia tehtäviä, voit ottaa kurssin repositorioista [edellisen viikon mallivastauksen](https://github.com/mluukkai/WebPalvelinohjelmointi2014/tree/master/malliv/viikko4). Jos sait suurimman osan edellisen viikon tehtävistä tehtyä, saattaa olla helpointa, että täydennät vastaustasi mallivastauksen avulla.

Jos otat edellisen viikon mallivastauksen tämän viikon pohjaksi, kopioi hakemisto muualle kurssirepositorion alta (olettaen että olet kloonannut sen) ja tee sovelluksen sisältämästä hakemistosta uusi repositorio. 

**Huom:** muutamilla Macin käyttäjillä oli ongelmia Herokun tarvitseman pg-gemin kanssa. Paikallisesti gemiä ei tarvita ja se määriteltiinkin asennettavaksi ainoastaan tuotantoympäristöön. Jos ongelmia ilmenee, voit asentaa gemit antamalla <code>bundle install</code>-komentoon seuraavan lisämääreen:

    bundle install --without production

Tämä asetus muistetaan jatkossa, joten pelkkä `bundle install` riittää kun haluat asentaa uusia riippuvuuksia.

## Mashup: baarien haku 

Suuri osa internetin palveluista hyödyntää nykyään joitain avoimia rajapintoja, joiden tarjoaman datan avulla sovellukset voivat rikastaa omaa toiminnallisuuttaan.

Myös oluihin liittyviä avoimia rajapintoja on tarjolla, ks. http://www.programmableweb.com/ hakusanalla beer

Tämän hetken tarjolla olevista rajapinnoista parhaalta näyttää http://www.programmableweb.com/api/brewery-db 
jonka ilmainen käyttö on kuitenkin rajattu 400 päivittäiseen kyselyyn, joten emme tällä kertaa käytä sitä, vaan Beermapping API:a (ks. http://www.programmableweb.com/api/beer-mapping ja http://beermapping.com/api/), joka tarjoaa mahdollisuuden oluita tarjoilevien ravintoloiden tietojen etsintään.

Beermapingin API:a käyttävät sovellukset tarvitsevat yksilöllisen API-avaimen. Saat avaimen sivulta http://beermapping.com/api/request_key, vastaava käytäntö on olemassa hyvin suuressa osassa nykyään tarjolla olevissa avoimissa rajapinnoissa.

API:n tarjoamat palvelut on listattu sivulla http://beermapping.com/api/reference/

Saamme esim. selville tietyn paikkakunnan olutravintolat tekemällä HTTP-get-pyynnön osoitteeseen <code>http://beermapping.com/webservice/loccity/[apikey]/[city]<location></code> 

Paikkakunta siis välitetään osana URL:ia. 

Kyselyjen tekemistä voi kokeilla selaimella tai komentoriviltä curl-ohjelmalla. Saamme esimerkiksi Espoon olutravintolat selville seuraavasti:

```ruby
mbp-18:ratebeer mluukkai$ curl http://beermapping.com/webservice/loccity/96ce1942872335547853a0bb3b0c24db/espoo
<?xml version='1.0' encoding='utf-8' ?><bmp_locations><location><id>12411</id><name>Gallows Bird</name><status>Brewery</status><reviewlink>http://beermapping.com/maps/reviews/reviews.php?locid=12411</reviewlink><proxylink>http://beermapping.com/maps/proxymaps.php?locid=12411&amp;d=5</proxylink><blogmap>http://beermapping.com/maps/blogproxy.php?locid=12411&amp;d=1&amp;type=norm</blogmap><street>Merituulentie 30</street><city>Espoo</city><state></state><zip>02200</zip><country>Finland</country><phone>+358 9 412 3253</phone><overall>91.66665</overall><imagecount>0</imagecount></location></bmp_locations>mbp-18:ratebeer mluukkai$
```

Kuten huomaamme, vastaus tulee XML-muodossa. Käytänne on hieman vanhahtava, sillä tällä hetkellä ylivoimaisesti suosituin web-palveluiden välillä käytettävä tiedonvaihdon formaatti on json.

Selaimella näemme palautetun XML:n hieman ihmisluettavammassa muodossa:

![kuva](https://github.com/mluukkai/WebPalvelinohjelmointi2014/raw/master/images/ratebeer-w5-1.png)

**HUOM: älä käytä tässä näytettyä API-avainta vaan rekisteröi itsellesi oma avain.**

Tehdään nyt sovellukseemme olutravintoloita etsivä tominnallisuus.

Luodaan tätä varten sivu osoitteeseen places, eli määritellään route.rb:hen

    get 'places', to: 'places#index'

ja luodaan kontrolleri:

```ruby
class PlacesController < ApplicationController
  def index
  end
end
```

ja näkymä app/views/places/index.html.erb, joka aluksi ainoastaan näyttää hakuun tarvittavan lomakkeen:

```erb
<h1>Beer places search</h1>

<%= form_tag places_path do %>
  city <%= text_field_tag :city, params[:city] %>
  <%= submit_tag "Search" %>
<% end %>
```

Lomake siis lähettää HTTP POST -kutsun places_path:iin. Määritellään tälle oma reitti routes.rb:hen

    post 'places', to:'places#search'

Päätimme siis että metodin nimi on <code>search</code>. Laajennetaan kontrolleria seuraavasti:

```ruby
class PlacesController < ApplicationController
  def index
  end

  def search
    render :index
  end
end
```

Ideana on se, että <code>search</code>-metodi hakee panimoiden listan beermapping API:sta, jonka jälkeen panimot listataan index.html:ssä eli tämän takia metodin <code>search</code> lopussa renderöidään näkymätemplate <code>index</code>.

Kontrollerista metodissa <code>search</code> on siis tehtävä HTTP-kysely beermappin API:n sivulle. Eräs hyvä tapa HTTP-kutsujen tekemiseen Rubyllä on HTTParty-gemin käyttö ks. https://github.com/jnunemaker/httparty. Lisätään seuraava Gemfileen:

    gem 'httparty'

Otetaan uusi gem käyttöön suorittamalla komentoriviltä tuttu komento <code>bundle install</code>

Kokeillaan nyt etsiä konsolista käsin Helsingin ravintoloita (muista uudelleenkäynnistää konsoli):

```ruby
irb(main):001:0> api_key = "96ce1942872335547853a0bb3b0c24db"
=> "96ce1942872335547853a0bb3b0c24db"
irb(main):002:0>  url = "http://beermapping.com/webservice/loccity/#{api_key}/"
=> "http://beermapping.com/webservice/loccity/96ce1942872335547853a0bb3b0c24db/"
irb(main):003:0> HTTParty.get url+"helsinki"
=> #<HTTParty::Response:0x7fd778a6d590 …>
```

Kutsu siis palauttaa luokan <code>HTTParty::Response</code>-olion. Oliolta voidaan kysyä esim. vastaukseen liittyvät headerit:

```ruby
irb(main):004:0> response = HTTParty.get(url+"helsinki")
irb(main):005:0> response.headers
=> {"date"=>["Sun, 02 Feb 2014 17:23:08 GMT"], "server"=>["Apache"], "expires"=>["Mon, 26 Jul 1997 05:00:00 GMT"], "last-modified"=>["Sun, 02 Feb 2014 17:23:08 GMT"], "cache-control"=>["no-store, no-cache, must-revalidate", "post-check=0, pre-check=0"], "pragma"=>["no-cache"], "vary"=>["Accept-Encoding"], "content-length"=>["3801"], "connection"=>["close"], "content-type"=>["text/xml"]}
irb(main):006:0> 
```

ja HTTP-kutsun statuskoodi:

```ruby
irb(main):006:0> response.code
=> 200
```

Statuskoodi ks. http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html on tällä kertaa 200 eli ok, kutsu on siis onnistunut.

Vastausolion metodi <code>parsed_response</code> palauttaa metodin palauttaman datan rubyn hashina:

```ruby
irb(main):007:0> response.parsed_response
=> {"bmp_locations"=>{"location"=>[{"id"=>"6742", "name"=>"Pullman Bar", "status"=>"Beer Bar", "reviewlink"=>"http://beermapping.com/maps/reviews/reviews.php?locid=6742", "proxylink"=>"http://beermapping.com/maps/proxymaps.php?locid=6742&d=5", "blogmap"=>"http://beermapping.com/maps/blogproxy.php?locid=6742&d=1&type=norm", "street"=>"Kaivokatu 1", "city"=>"Helsinki", "state"=>nil, "zip"=>"00100", "country"=>"Finland", "phone"=>"+358 9 0307 22", "overall"=>"72.500025", "imagecount"=>"0"}, {"id"=>"6743", "name"=>"Belge", "status"=>"Beer Bar", "reviewlink"=>"http://beermapping.com/maps/reviews/reviews.php?locid=6743", "proxylink"=>"http://beermapping.com/maps/proxymaps.php?locid=6743&d=5", "blogmap"=>"http://beermapping.com/maps/blogproxy.php?locid=6743&d=1&type=norm", "street"=>"Kluuvikatu 5", "city"=>"Helsinki", "state"=>nil, "zip"=>"00100", "country"=>"Finland", "phone"=>"+358 10 766 35", "overall"=>"67.499925", "imagecount"=>"1"}, {"id"=>"6919", "name"=>"Suomenlinnan Panimo", "status"=>"Brewpub", "reviewlink"=>"http://beermapping.com/maps/reviews/reviews.php?locid=6919", "proxylink"=>"http://beermapping.com/maps/proxymaps.php?locid=6919&d=5", "blogmap"=>"http://beermapping.com/maps/blogproxy.php?locid=6919&d=1&type=norm", "street"=>"Rantakasarmi", "city"=>"Helsinki", "state"=>nil, "zip"=>"00190", "country"=>"Finland", "phone"=>"+358 9 228 5030", "overall"=>"69.166625", "imagecount"=>"0"}, {"id"=>"12408", "name"=>"St. Urho's Pub", "status"=>"Beer Bar", "reviewlink"=>"http://beermapping.com/maps/reviews/reviews.php?locid=12408", "proxylink"=>"http://beermapping.com/maps/proxymaps.php?locid=12408&d=5", "blogmap"=>"http://beermapping.com/maps/blogproxy.php?locid=12408&d=1&type=norm", "street"=>"Museokatu 10", "city"=>"Helsinki", "state"=>nil, "zip"=>"00100", "country"=>"Finland", "phone"=>"+358 9 5807 7222", "overall"=>"95", "imagecount"=>"0"}, {"id"=>"12409", "name"=>"Kaisla", "status"=>"Beer Bar", "reviewlink"=>"http://beermapping.com/maps/reviews/reviews.php?locid=12409", "proxylink"=>"http://beermapping.com/maps/proxymaps.php?locid=12409&d=5", "blogmap"=>"http://beermapping.com/maps/blogproxy.php?locid=12409&d=1&type=norm", "street"=>"Vilhonkatu 4", "city"=>"Helsinki", "state"=>nil, "zip"=>"00100", "country"=>"Finland", "phone"=>"+358 10 76 63850", "overall"=>"83.3334", "imagecount"=>"0"}, {"id"=>"12410", "name"=>"Pikkulintu", "status"=>"Beer Bar", "reviewlink"=>"http://beermapping.com/maps/reviews/reviews.php?locid=12410", "proxylink"=>"http://beermapping.com/maps/proxymaps.php?locid=12410&d=5", "blogmap"=>"http://beermapping.com/maps/blogproxy.php?locid=12410&d=1&type=norm", "street"=>"Klaavuntie 11", "city"=>"Helsinki", "state"=>nil, "zip"=>"00910", "country"=>"Finland", "phone"=>"+358 9 321 5040", "overall"=>"91.6667", "imagecount"=>"0"}, {"id"=>"18418", "name"=>"Bryggeri Helsinki", "status"=>"Brewpub", "reviewlink"=>"http://beermapping.com/maps/reviews/reviews.php?locid=18418", "proxylink"=>"http://beermapping.com/maps/proxymaps.php?locid=18418&d=5", "blogmap"=>"http://beermapping.com/maps/blogproxy.php?locid=18418&d=1&type=norm", "street"=>"Sofiankatu 2", "city"=>"Helsinki", "state"=>nil, "zip"=>"FI-00170", "country"=>"Finland", "phone"=>"010 235 2500", "overall"=>"0", "imagecount"=>"0"}]}}
irb(main):008:0> 
```

Vaikka palvelin siis palauttaa vastauksensa XML-muodossa, parsii HTTParty-gem vastauksen ja mahdollistaa sen käsittelyn suoraan miellyttävämmässä muodossa Rubyn hashinä.

Kutsun palauttamat ravintolat sisältävä taulukko saadaan seuraavasti:

```ruby
irb(main):042:0> places = response.parsed_response["bmp_locations"]["location"]
irb(main):043:0> places.size
=> 7
 => 6 
```

Helsingistä tunnetaan siis 7 paikkaa. Tutkitaan ensimmäistä:

```ruby
irb(main):044:0> places.first
=> {"id"=>"6742", "name"=>"Pullman Bar", "status"=>"Beer Bar", "reviewlink"=>"http://beermapping.com/maps/reviews/reviews.php?locid=6742", "proxylink"=>"http://beermapping.com/maps/proxymaps.php?locid=6742&d=5", "blogmap"=>"http://beermapping.com/maps/blogproxy.php?locid=6742&d=1&type=norm", "street"=>"Kaivokatu 1", "city"=>"Helsinki", "state"=>nil, "zip"=>"00100", "country"=>"Finland", "phone"=>"+358 9 0307 22", "overall"=>"72.500025", "imagecount"=>"0"}
irb(main):045:0> places.first.keys
=> ["id", "name", "status", "reviewlink", "proxylink", "blogmap", "street", "city", "state", "zip", "country", "phone", "overall", "imagecount"]
irb(main):046:0> 
```

Jälkimmäinen komento <code>locations.first.keys</code> kertoo mitä kenttiä ravintoloihin liittyy. 

Luodaan panimoiden esittämiseen oma olio, kutsuttakoon sitä nimellä <code>Place</code>. Sijoitetaan luokka models-hakemistoon. 

```ruby
class Place
  include ActiveModel::Model

  attr_accessor :id, :name, :status, :reviewlink, :proxylink, :blogmap, :street, :city, :state, :zip, :country, :phone, :overall, :imagecount
end
```

Koska kyseessä ei ole "normaali" luokan <codeActiveRecord::Base</code> perivä luokka, joudumme määrittelemään metodin <code>attr_accessor</code> avulla olion attribuutit. Metodi luo jokaista parametrina olevaa symbolia kohti "getterin ja setterin", eli metodit attribuutin arvon lukemista ja päivittämistä varten.

Olioon on määritelty attribuutti kaikille beermappingin yhtä ravintolaa kohti palauttamille kentille. 

Luokkaan on sisällytetty moduuli <code>ActiveModel::Model</code> (ks. http://api.rubyonrails.org/classes/ActiveModel/Model.html), joka mahdollistaa mm. konstruktorissa kaikkien attribuuttien alustamisen suoraan API:n palauttaman hashin perusteella. Eli voimme luoda API:n palauttamasta datasta Place-olioita seuraavasti:

```ruby
irb(main):053:0> baari = Place.new places.first
=> #<Place:0x007fd7799c3dc8 @id="6742", @name="Pullman Bar", @status="Beer Bar", @reviewlink="http://beermapping.com/maps/reviews/reviews.php?locid=6742", @proxylink="http://beermapping.com/maps/proxymaps.php?locid=6742&d=5", @blogmap="http://beermapping.com/maps/blogproxy.php?locid=6742&d=1&type=norm", @street="Kaivokatu 1", @city="Helsinki", @state=nil, @zip="00100", @country="Finland", @phone="+358 9 0307 22", @overall="72.500025", @imagecount="0">
irb(main):054:0> baari.name
=> "Pullman Bar"
irb(main):055:0> baari.street
=> "Kaivokatu 1"
irb(main):056:0> 
```

Kirjoitetaan sitten kontrolleriin alustava koodi. Kovakoodataan etsinnän tapahtuvan aluksi Helsingistä ja luodaan ainoastaan ensimmäisestä löydetystä paikasta Place-olio:

```ruby
class PlacesController < ApplicationController
  def index
  end

  def search
    api_key = "96ce1942872335547853a0bb3b0c24db"
    url = "http://beermapping.com/webservice/loccity/#{api_key}/"
    response = HTTParty.get "#{url}helsinki"
    places_from_api = response.parsed_response["bmp_locations"]["location"]
    @places = [ Place.new(places_from_api.first) ]

    render :index
  end
end
```

Muokataan app/views/places/index.html.erb:tä siten, että se näyttää löydetyt ravintolat

```erb
<h1>Beer places search</h1>

<%= form_tag places_path do %>
  city <%= text_field_tag :city, params[:city] %>
  <%= submit_tag "Search" %>
<% end %>

<% if @places %>
  <ul>
    <% @places.each do |place| %>
      <li><%=place.name %></li>
    <% end %>
  </ul>
<% end %>
```

Koodi vaikuttaa toimivalta (huom. joudut uudelleenkäynnistämään Rails serverin jotta HTTParty-gem tulee ohjelman käyttöön). 

Laajennetaan sitten koodi näyttämään kaikki panimot ja käyttämään lomakkeelta tulevaa parametria haettavana paikkakuntana:

```ruby
  def search
    api_key = "96ce1942872335547853a0bb3b0c24db"
    url = "http://beermapping.com/webservice/loccity/#{api_key}/"
    response = HTTParty.get "#{url}#{params[:city]}"

    @places = response.parsed_response["bmp_locations"]["location"].inject([]) do | set, place |
      set << Place.new(place)
    end

    render :index
  end
```

Sovellus toimii muuten, mutta jos haetulla paikkakunnalla ei ole ravintoloita, tapahtuu virhe. 

Sopivilla debug-tulostuksilla huomaamme, että näissä tapauksissa API:n palauttama paikkojen lista näyttää seuraavalta:

```ruby
{"id"=>nil, "name"=>nil, "status"=>nil, "reviewlink"=>nil, "proxylink"=>nil, "blogmap"=>nil, "street"=>nil, "city"=>nil, "state"=>nil, "zip"=>nil, "country"=>nil, "phone"=>nil, "overall"=>nil, "imagecount"=>nil}
```

Eli paluuarvona on hash. Jos taas haku löytää oluita paluuarvo on taulukko, jonka sisällä on hashejä. Virittelemme koodia ottamaan tämän huomioon. Koodi huomioi myös mahdollisuuden, jossa API palauttaa hashin, joka ei kuitenkaan vastaa olemassaolematonta paikkaa.

```ruby
class PlacesController < ApplicationController
  def index
  end

  def search
    api_key = "96ce1942872335547853a0bb3b0c24db"
    url = "http://beermapping.com/webservice/loccity/#{api_key}/"
    response = HTTParty.get "#{url}#{params[:city]}"
    places = response.parsed_response["bmp_locations"]["location"]

    if places.is_a?(Hash) and places['id'].nil?
      redirect_to places_path, :notice => "No places in #{params[:city]}"
    else
      places = [places] if places.is_a?(Hash)
      @places = places.inject([]) do | set, location|
        set << Place.new(location)
      end
      render :index
    end
  end

end
```

Koodi on tällä hetkellä rumaa, mutta parantelemme sitä hetken kuluttua. Näytetään baareista enemmän tietoja sivulla. Määritellään näytettävät kentät Place-luokan staattisena metodina:

```ruby
class Place
  include ActiveModel::Model
  attr_accessor :id, :name, :status, :reviewlink, :proxylink, :blogmap, :street, :city, :state, :zip, :country, :phone, :overall, :imagecount

  def self.rendered_fields
    [:id, :name, :status, :street, :city, :zip, :country, :overall ]
  end
end
```

index.html.erb:n paranneltu koodi seuraavassa:

```erb
<p id="notice"><%= notice %></p>

<%= form_tag places_path do %>
  city <%= text_field_tag :city, params[:city] %>
  <%= submit_tag "Search" %>
<% end %>

<% if @places %>
  <table>
    <thead>
      <% Place.rendered_fields.each do |f| %>
        <td><%=f %></td>
      <% end %>
    </thead>
    <% @places.each do |place| %>
      <tr>
        <% Place.rendered_fields.each do |f| %>
          <td><%= place.send(f) %></td>
        <% end %>
      </tr>
    <% end %>
  </table>
<% end %>
```

Sovelluksessamme on vielä pieni ongelma Jos yritämme etsiä New Yorkin olutravintoloita on seurauksena virhe. Välilyönnit on korvattava URL:ssä koodilla %20. Korvaamista ei kannata tehdä itse 'käsin', välilyönti ei nimittäin ole ainoa merkki joka on koodattava URL:iin. Kuten arvata saattaa, on Railsissa tarjolla tarkoitusta varten valmis metodi <code>ERB::Util.url_encode</code>. Kokeillaan metodia konsolista:

```ruby
irb(main):063:0> ERB::Util.url_encode("St John's")
=> "St%20John%27s"
irb(main):064:0>
```

Tehdään nyt muutos koodiin korvaamalla HTTP GET -pyynnön tekevä rivi seuraavalla:

```ruby
    response = HTTParty.get "#{url}#{ERB::Util.url_encode(params[:city])}"
```

> ## Tehtävä 1
>
> Tee edelläoleva koodi ohjelmaasi. Lisää myös navigointipalkkiin linkki olutpaikkojen hakusivulle

## Places-kontrollerin refaktorointi

Railsissa kontrollereiden ei tulisi sisältää sovelluslogiikkaa. Ulkopuoleisen API:n käyttö onkin syytä eristää omaksi luokakseen. Sijoitetaan luokka lib-hakemistoon (tiedostoon beermapping_api.rb):

```ruby
class BeermappingApi
  def self.places_in(city)
    url = "http://beermapping.com/webservice/loccity/#{key}/"

    response = HTTParty.get "#{url}#{ERB::Util.url_encode(city)}"
    places = response.parsed_response["bmp_locations"]["location"]

    return [] if places.is_a?(Hash) and places['id'].nil?

    places = [places] if places.is_a?(Hash)
    places.inject([]) do | set, place |
      set << Place.new(place)
    end
  end

  def self.key
    "96ce1942872335547853a0bb3b0c24db"
  end
end
```

Luokka siis määrittelee stattisen metodin, joka palauttaa taulukon parametrina määritellystä kaupungista löydetyistä olutpaikoista. Jos paikkoja ei löydy, on taulukko tyhjä. API:n eristävä luokka ei ole vielä viimeiseen asti hiotussa muodossa, sillä emme vielä täysin tiedä mitä muita metodeja tarvitsemme.

**HUOM:** jos et tehnyt [viikon 2 tehtävää 15](https://github.com/mluukkai/WebPalvelinohjelmointi2014/blob/master/web/viikko2.md#teht%C3%A4v%C3%A4-15) tai sijoitit tehtävässä määritellyn moduulin hakemistoon _app/models/concers_, lisää tiedostoon _config/application.rb_ luokan <code>Application</code> määrittelyn sisälle rivi <code>config.autoload_paths += Dir["#{Rails.root}/lib"]</code>, jotta Rails lataisi lib-hakemistoon sijoitetun koodin sovelluksen luokkien käyttöön.

Kontrollerista tulee nyt siisti:

```ruby
class PlacesController < ApplicationController
  def index
  end

  def search
    @places = BeermappingApi.places_in(params[:city])
    if @places.empty?
      redirect_to places_path, notice: "No locations in #{params[:city]}"
    else
      render :index
    end
  end
end
```

## Olutpaikkojen etsimistoiminnon testaaminen

Tehdään seuraavaksi Rspec-testejä toteuttamallemme toiminnallisuudelle. Uusi toiminnallisuutemme käyttää siis hyväkseen ulkoista palvelua. Testit on kuitenkin syytä kirjoittaa siten, ettei ulkoista palvelua käytetä. Onneksi ulkoisen rajapinnan korvaaminen stub-komponentilla on Railsissa helppoa.

Päätämme jakaa testit kahteen osaan. Korvaamme ensin ulkoisen rajapinnan kapseloivan luokan <code>BeermappingApi</code> toiminnallisuuden stubien avulla kovakoodatulla toiminnallisuudella. Testi siis testaa, toimiiko places-sivu oikein olettaen, että <code>BeermappingApi</code>-komponentti toimii.

Testaamme sitten erikseen Rspecillä kirjoitettavilla yksikkötesteillä <code>BeermappingApi</code>-komponentin toiminnan.

Aloitetaan siis web-sivun places-toiminnallisuuden testaamisesta. Tehdään testiä varten tiedosto /spec/features/places_spec.rb

```ruby
require 'spec_helper'

describe "Places" do
  it "if one is returned by the API, it is shown at the page" do
    BeermappingApi.stub(:places_in).with("kumpula").and_return(
        [ Place.new(:name => "Oljenkorsi") ]
    )

    visit places_path
    fill_in('city', with: 'kumpula')
    click_button "Search"

    expect(page).to have_content "Oljenkorsi"
  end
end
```

Testi alkaa heti mielenkiintoisella komennolla:

```ruby
BeermappingApi.stub(:places_in).with("kumpula").and_return( [  Place.new(:name => "Oljenkorsi") ] )
```

Komento "kovakoodaa" luokan <code>BeermappingApi</code> metodin <code>places_in</code> vastaukseksi määritellyn yhden Place-olion sisältävän taulukon, jos metodia kutsutaan parametrilla "kumpula". 

Kun nyt testissä tehdään HTTP-pyyntö places-kontrollerille, ja kontrolleri kutsuu API:n metodia <code>places_in</code>, metodin todellisen koodin suorittamisen sijaan places-kontrollerille palautetaankin kovakoodattu vastaus.

Jos törmäät testejä suorittaessasi virheeseen
```ruby
mbp-18:ratebeer mluukkai$ rspec spec/features/places_spec.rb 
/Users/mluukkai/.rbenv/versions/2.0.0-p247/lib/ruby/gems/2.0.0/gems/activerecord-4.0.2/lib/active_record/migration.rb:379:in `check_pending!': Migrations are pending; run 'bin/rake db:migrate RAILS_ENV=test' to resolve this issue. (ActiveRecord::PendingMigrationError)
…
```

Syynä tälle on se, että testiympäristössä ei ole suoritettu kaikkia tietokantamigraatioita. Ongelma korjaantuu komennolla <code>rake db:test:prepare</code>

> ## Tehtävä 2
>
> Laajenna testiä kattamaan seuraavat tapaukset:
> * jos API palauttaa useita olutpaikkoja, kaikki näistä näytetään sivulla
> * jos API ei löydä paikkakunnalta yhtään olutpaikkaa (eli paluuarvo on tyhjä taulukko), sivulla näytetään ilmoitus "No locations in <<etsitty paikka>>" 

Siirrytään sitten luokan <code>BeermappingApi</code> testaamiseen. Luokka siis tekee HTTP GET -pyynnön HTTParty-kirjaston avulla Beermapping-palveluun. Voisimme edellisen esimerkin tapaan stubata HTTPartyn get-metodin. Tämän on kuitenkin hieman ikävää, sillä metodi palauttaa <code>HTTPartyResponse</code>-olion ja sellaisen muodostaminen stubauksen yhteydessä käsin ei välttämättä ole kovin mukavaa. 

Parempi vaihtoehto onkin käyttää gemiä _webmock_ https://github.com/bblimke/webmock/ sillä se mahdollistaa stubauksen HTTPartyn käyttämän kirjaston tasolla.

Otetaan gem käyttöön lisäämällä Gemfilen **test-scopeen** rivi

    gem 'webmock'

ja suoritetaan <code>bundle install</code>.

Tiedostoon ```spec/spec_helper.rb``` pitää vielä lisätä rivi:

```ruby
require 'webmock/rspec'
```

Webmock-kirjaston käyttö on melko helppoa. Esim. seuraava komento stubaa _jokaiseen_ URLiin (määritelty regexpillä <code>/.*/</code>) tulevan GET-pyynnön palauttamaan 'Lapin kullan' tiedot XML-muodossa:

```ruby
stub_request(:get, /.*/).to_return(body:"<beer><name>Lapin kulta</name><brewery>Hartwall</brewery></beer>", headers:{ 'Content-Type' => "text/xml" })
```

Eli jos kutsuisimme komennon tehtyämme esim. <code>HTTParty.get("http://www.google.com")</code> olisi vastauksena 

```xml
<beer>
  <name>Lapin kulta</name>
  <brewery>Hartwall</brewery>
</beer>
```

Tarvitsemme siis testiämme varten sopivan "kovakoodatun" datan, joka kuvaa Beermapping-palvelun HTTP GET -pyynnön palauttamaa XML:ää. 

Eräs tapa testisyötteen generointiin on kysyä se rajapinnalta itseltään, eli tehdään komentoriviltä <code>curl</code>-komennolla HTTP GET -pyyntö:

```ruby
mbp-18:ratebeer mluukkai$ curl  http://beermapping.com/webservice/loccity/96ce1942872335547853a0bb3b0c24db/tampere
<?xml version='1.0' encoding='utf-8' ?><bmp_locations><location><id>13307</id><name>O'Connell's Irish Bar</name><status>Beer Bar</status><reviewlink>http://beermapping.com/maps/reviews/reviews.php?locid=13307</reviewlink><proxylink>http://beermapping.com/maps/proxymaps.php?locid=13307&amp;d=5</proxylink><blogmap>http://beermapping.com/maps/blogproxy.php?locid=13307&amp;d=1&amp;type=norm</blogmap><street>Rautatienkatu 24</street><city>Tampere</city><state></state><zip>33100</zip><country>Finland</country><phone>35832227032</phone><overall>0</overall><imagecount>0</imagecount></location></bmp_locations>mbp-18:ratebeer mluukkai$ 
```

Nyt voimme copypastata HTTP-pyynnön palauttaman XML-muodossa olevan tiedon testiimme. Jotta saamme XML:n varmasti oikein sijoitetuksi merkkijonoon, käytämme hieman erikoista syntaksia
ks. http://blog.jayfields.com/2006/12/ruby-multiline-strings-here-doc-or.html jossa merkkijono sijoitetaan merkkien <code><<-END_OF_STRING</code> ja <code>END_OF_STRING</code> väliin.

Seuraavassa tiedostoon spec/lib/beermapping_api_spec.rb  sijoitettava testikoodi (päätimme sijoittaa koodin alihakemistoon lib koska testin kohde on lib-hakemistossa oleva apuluokka):

```ruby
require 'spec_helper'

describe "BeermappingApi" do
  it "When HTTP GET returns one entry, it is parsed and returned" do

    canned_answer = <<-END_OF_STRING
<?xml version='1.0' encoding='utf-8' ?><bmp_locations><location><id>13307</id><name>O'Connell's Irish Bar</name><status>Beer Bar</status><reviewlink>http://beermapping.com/maps/reviews/reviews.php?locid=13307</reviewlink><proxylink>http://beermapping.com/maps/proxymaps.php?locid=13307&amp;d=5</proxylink><blogmap>http://beermapping.com/maps/blogproxy.php?locid=13307&amp;d=1&amp;type=norm</blogmap><street>Rautatienkatu 24</street><city>Tampere</city><state></state><zip>33100</zip><country>Finland</country><phone>35832227032</phone><overall>0</overall><imagecount>0</imagecount></location></bmp_locations>
    END_OF_STRING

    stub_request(:get, /.*tampere/).to_return(body: canned_answer, headers: { 'Content-Type' => "text/xml" })

    places = BeermappingApi.places_in("tampere")

    expect(places.size).to eq(1)
    place = places.first
    expect(place.name).to eq("O'Connell's Irish Bar")
    expect(place.street).to eq("Rautatienkatu 24")
  end

end
```

Testi siis ensin määrittelee, että URL:iin joka loppuu merkkijonoon "tampere" (määritelty regexpillä <code>/.*tampere/</code>) kohdistuvan  HTTP GET -kutsun palauttamaan kovakoodatun XML:n, HTTP-kutsun palauttamaan headeriin määritellään, että palautettu tieto on XML-muodossa. Ilman tätä määritystä HTTParty-kirjasto ei osaa parsia HTTP-pyynnön palauttamaa dataa oiken. 

Itse testi tapahtuu suoraviivaisesti tarkastelemalla BeermappingApi:n metodin <code>places_in</code> palauttamaa taulukkoa.

*Huom:* stubasimme testissä ainoastaan merkkijonoon "tampere" loppuviin URL:eihin (<code>/.*tampere/</code>) kohdistuvat HTTP GET -kutsut. Jos testin suoritus aiheuttaa jonkin muunlaisen HTTP-kutsun, huomauttaa testi tästä:

```ruby
) BeermappingApi When HTTP GET returns no entries, an empty array is returned
     Failure/Error: places = BeermappingApi.places_in("kumpula")
     WebMock::NetConnectNotAllowedError:
       Real HTTP connections are disabled. Unregistered request: GET http://beermapping.com/webservice/loccity/96ce1942872335547853a0bb3b0c24db/kumpula
       
       You can stub this request with the following snippet:
       
       stub_request(:get, "http://beermapping.com/webservice/loccity/96ce1942872335547853a0bb3b0c24db/kumpula").
         to_return(:status => 200, :body => "", :headers => {})
```

Kuten virheilmoitus antaa ymmärtää, voidaan komennon <code>stub_request</code> avulla stubata myös merkkijonona määriteltyyn yksittäiseen URL:iin kohdistuva HTTP-kutsu. Sama testi voi myös sisältää useita <code>stub_request</code>-kutsuja, jotka kaikki määrittelevät eri URLeihin kohdistuvien pyyntöjen vastaukset.

> ## Tehtävä 3
>
> Laajenna testejä kattamaan seuraavat tapaukset
> * HTTP GET ei palauta yhtään paikkaa, eli tällöin metodin <code>places_in</code> tulee palauttaa tyhjä taulukko
> * HTTP GET palauttaa useita paikkoja, eli tällöin metodin <code>places_in</code> tulee palauttaa kaikki HTTP-kutsun XML-muodossa palauttamat ravintolat taulukollisena Place-olioita
>
> Stubatut vastaukset kannattaa jälleen muodostaa curl-komennon avulla API:n tehdyillä kyselyillä

Erilaisten lavastekomponenttien tekeminen eli metodien ja kokonaisten olioiden stubaus sekä mockaus on hyvin laaja aihe. Voit lukea aiheesta Rspeciin liittyen seuraavasta http://rubydoc.info/gems/rspec-mocks/

Nimityksiä stub- ja mock-olio tai "stubaaminen ja mockaaminen" käytetään usein varsin huolettomasti. Onneksi Rails-yhteisö käyttää termejä oikein. Lyhyesti ilmaistuna stubit ovat olioita, joihin on kovakoodattu valmiiksi metodien vastauksia. Mockit taas toimivat myös stubien tapaan kovakoodattujen vastausten antajana, mutta sen lisäksi mockien avulla voidaan määritellä odotuksia siitä miten niiden metodeja kutsutaan. Jos testattavana olevat olit eivät kutsu odotetulla tavalla mockien metodeja, aiheutuu tästä testivirhe.

Mockeista ja stubeista lisää esim. seuraavassa: http://martinfowler.com/articles/mocksArentStubs.html

## Suorituskyvyn optimointi

Tällä hetkellä sovelluksemme toimii siten, että se tekee kyselyn beermappingin palveluun aina kun jonkin kaupungin ravintoloita haetaan. Voisimme tehostaa sovellusta muistamalla viime aikoina suoritettuja hakuja.

Rails tarjoaa avain-arvopari-periaatteella toimivan hyvin helppokäyttöisen cachen eli välimuistin sovelluksen käyttöön. Kokeillaan konsolista:

```ruby
irb(main):001:0> Rails.cache.write "helsinki", "dataa"
=> true
irb(main):002:0> Rails.cache.read "helsinki"
=> "dataa"
irb(main):003:0> Rails.cache.read "kumpula"
=> nil
irb(main):004:0> Rails.cache.write "kumpula", Place.new(name:"Oljenkorsi")
=> true
irb(main):005:0> Rails.cache.read "kumpula"
=> #<Place:0x007fbedbf2d770 @name="Oljenkorsi">
irb(main):006:0> 
```

Cacheen voi tallettaa melkein mitä vaan. Ja rajapinta on todella yksinkertainen, ks. http://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html 

Metodien <code>read</code> ja <code>write</code> lisäksi Railsin cache tarjoaa joihinkin tilanteisiin todella hyvin sopivan metodin <code>fetch</code>. Metodille annetaan välimuistista haettavan avaimen lisäksi koodilohko, joka suoritetaan ja talletetaan avaimen arvoksi _jos_ avaimella ei ole jo talletettuna arvoa ennestään. 

Esim. komento <code>Rails.cache.fetch("first_user") { User.first }</code> hakee välimuistista avaimella *first_user* talletutun olion. Jos avaimelle ei ole vielä talletettu arvoa, suortetaan komento <code>User.first</code>, ja talletetaan sen palauttama olio avaimen arvoksi. Seuraavassa esimerkki:


```ruby
irb(main):016:0> Rails.cache.fetch("first_user") { User.first }
  User Load (0.5ms)  SELECT "users".* FROM "users" ORDER BY "users"."id" ASC LIMIT 1
=> #<User id: 1, username: "mluukkai", created_at: "2014-01-30 18:13:47", updated_at: "2014-01-30 18:19:02", password_digest: "$2a$10$HqCLH1qJ4RDE4V84fLTljurRnhqP7delBa/HWfuPxVAs...", admin: true>
irb(main):017:0> Rails.cache.fetch("first_user") { User.first }
=> #<User id: 1, username: "mluukkai", created_at: "2014-01-30 18:13:47", updated_at: "2014-01-30 18:19:02", password_digest: "$2a$10$HqCLH1qJ4RDE4V84fLTljurRnhqP7delBa/HWfuPxVAs...", admin: true>
irb(main):018:0> 
```

Ensimmäinen metodikutsu siis aiheuttaa tietokantahaun ja tallettaa olion välimuistiin. Seuraava kutsu saa avainta vastaavan olion suoraan välimuistista.

Oletusarvoisesti Railsin cache tallettaa avain-arvo-parit keskusmuistiin. Cachen käyttämä talletustapa on kuitenkin konfiguroitavissa, ks. http://guides.rubyonrails.org/caching_with_rails.html#cache-stores 

Huom: tuotantokäytössä voi olla riskialtista käyttää Railsin oletusarvoista keskusmuistia käyttävää cachea, sillä cache saattaa pahimmillaan käyttää todella suuren määrän muistia. Parempi ratkaisu onkin esim. [Memcached](http://memcached.org/), ks. tarkemmin esim. https://devcenter.heroku.com/articles/building-a-rails-3-application-with-memcache

Viritellään luokkaa <code>BeermappingApi</code> siten, että se tallettaa tehtyjen kyselyjen tulokset välimuistiin. Jos kysely kohdistuu jo välimuistissa olevaan kaupunkiin, palautetaan tulos välimuistista.

```ruby
class BeermappingApi
  def self.places_in(city)
    city = city.downcase
    Rails.cache.fetch(city) { fetch_places_in(city) }
  end

  private

  def self.fetch_places_in(city)
    url = "http://beermapping.com/webservice/loccity/#{key}/"

    response = HTTParty.get "#{url}#{ERB::Util.url_encode(city)}"
    places = response.parsed_response["bmp_locations"]["location"]

    return [] if places.is_a?(Hash) and places['id'].nil?

    places = [places] if places.is_a?(Hash)
    places.inject([]) do | set, place |
      set << Place.new(place)
    end
  end

  def self.key
    "96ce1942872335547853a0bb3b0c24db"
  end
end
```

Avaimena käytetään pienillä kirjaimilla kirjoitettua kaupungin nimeä.
Käytössä on nyt metodi <code>fetch</code>, joka palauttaa välimuistissa olevat tiedot kaupungin olutravintoloista _jos_ ne löytyvät jo välimuistista. Jos välimuistissa ei vielä ole kapungin ravintoloiden tietoja, suoritetaan toisena parametrina oleva koodi <code>fetch_places_in(city)</code> joka hakee tiedot ja tallettaa ne välimuistiin.

Jos teemme nyt haun kaksi kertaa peräkkäin esim. New Yorkin oluista, huomaamme, että toisella kerralla vastaus tulee huomattavasti nopeammin.

Pääsemme sovelluksen välimuistiin tallettamaan dataan käsiksi myös konsolista:

```ruby
irb(main):025:0> Rails.cache.read("helsinki").map(&:name)
=> ["Pullman Bar", "Belge", "Suomenlinnan Panimo", "St. Urho's Pub", "Kaisla", "Pikkulintu", "Bryggeri Helsinki"]
irb(main):026:0> 
```

Konsolista käsin on myös mahdollista tarvittaessa poistaa tietylle avaimelle talletettu data:

```ruby
irb(main):028:0> Rails.cache.delete("helsinki")
=> nil
irb(main):029:0> Rails.cache.read("helsinki")
=> nil
irb(main):030:0> 
```

## Vanhentunut data

Välimuistin käytön ongelmana on mahdollinen tiedon epäajantasaisuus. Eli jos joku lisää ravintoloita beermappingin sivuille, välimuistissamme säilyy edelleen vanha data. Jollain tavalla tulisi siis huolehtia, että välimuistiin ei pääse jäämään liian vanhaa dataa. 

Yksi ratkasiu olisi aika ajoin nollata välimuistissa oleva data komennolla:

    Rails.cache.clear

Tilanteeseemme paremmin sopiva ratkaisu on määritellä välimuistiin talletettavalle datalle enimmäiselinikä.

> ## Tehtävä 4
>
> ### tämä ei ole viikon tärkein tehtävä, joten älä jää jumittamaan tähän jos kohtaat ongelmia  
>
> Määrittele välimustiin talletettaville ravintolatiedoille enimmäiselinikä, esim. 1 viikko. Testatessasi tehtävän toimintaa, kannattaa kuitenkin käyttää pienempää elinikää, esim. yhtä minuuttia.
>
> Tehtävän tekeminen ei edellytä kovin suuria muutoksia koodiisi, oikeastaan muutoksia tarvitaan vain _yhdelle_ riville. Tarvittavat vihjeet löydät sivulta http://guides.rubyonrails.org/caching_with_rails.html#activesupport-cache-store Ajan käsittelyssä auttaa http://guides.rubyonrails.org/active_support_core_extensions.html#time
>
> **Huom:** kuten aina, nytkin kannattaa testailla enimmäiseliniän asettamisen toimivuutta konsolista käsin!
>
> **Huom2:** jos saat välimuistin sekaisin, muista <code>Rails.cache.clear</code> ja <code>Rails.cache.delete avain</code> 


## Sovelluskohtaisen datan tallentaminen

Koodissamme API-key on nyt kirjoitettu sovelluksen koodiin. Tämä ei tietenkään ole järkevää. Railsissa on useita mahdollisuuksia konfiguraatiotiedon tallentamiseen, ks. esim. http://quickleft.com/blog/simple-rails-app-configuration-settings

Päätetään tallentaa API-key tietokantaan gemiä rails-settings-cached ks. https://github.com/huacnlee/rails-settings-cached käyttäen. Otetaan gem käyttöön lisäämällä Gemfileen

    gem "rails-settings-cached", "0.3.1"

Suoritetaan komentoriviltä <code>bundle install</code> ja generoidaan sitten asetukset tallettava tietokantataulu generaattorin avulla ja suoritetaan migraatio.

```ruby
mbp-18:ratebeer mluukkai$ rails g settings settings
      create  app/models/settings.rb
      create  db/migrate/20140203232852_create_settings.rb
mbp-18:ratebeer mluukkai$ rake db:migrate
```

Talletetaan API-avain konsolista (konsoli pitää ensin uudelleenkäynnistää):

```ruby
irb(main):001:0> Settings.beermapping_apikey = "96ce1942872335547853a0bb3b0c24db"
```

Muutetaan BeermappingAPI:n koodia siten, että se pyytää avaimen Settings-luokalta:

```ruby
class BeermappingAPI
  def self.locations_in(city)
  # ...

  def self.key
    Settings.beermapping_apikey
  end
end
```

Sovellus täytyy uudelleenkäynnistää tässä vaiheessa.

HUOM: Koska Railsissa on eri suoritusympäristö tietokantoineen sovelluskehitykselle (development), testaukselle (testing) ja tuotantokäyttöön, eivät nyt konsolista talletetut asetukset ole vielä käytössä muualla kuin development-ympäristössä. Joudut luonnollisesti tallettamaan API-avaimen myös herokun konsolista käsin siinä vaiheessa kun deployaat sovelluksesi uuden version.

Toinen varteenotettava vaihtoehto sovelluskohtaisen datan tallettamiseen ovat ympäristömuuttujat. Esimerkki seuraavassa:

Asetetaan ensin komentoriviltä ympäristömuuttujalle <code>APIKEY</code>

```ruby
mbp-18:ratebeer mluukkai$ export APIKEY="96ce1942872335547853a0bb3b0c24db"
```

Rails-sovellus pääsee ympäristömuuttujiin käsiksi hash-tyyppisen muuttujan <code>ENV</code> kautta:

```ruby
irb(main):002:0> ENV['APIKEY']
=> "96ce1942872335547853a0bb3b0c24db"
```

Ympäristömuuttujille on helppo asettaa arvo myös Herokussa, ks. 
https://devcenter.heroku.com/articles/config-vars

## Ravintolan sivu

> ## Tehtävät 5-6 (vastaa kahta tehtävää)
>
> Tee sovellukselle ominaisuus, jossa ravintolan nimeä klikkaamalla avautuu oma sivu, jossa on näkyvillä ravintolan tiedot. Sisällytä sivulle (esim. iframena) myös kartta, johon on merkattu ravintolan sijainti. Huomaa, että kartan url löytyy suoraan ravintolan tiedoista.
>* ravintolan urliksi kannattaa vailta Rails-konvention mukainen places/:id, routes.rb voi näyttää esim. seuraavalta:
>
>    resources :places, only:[:index, :show]
>
>    post "places", to:"places#search"
>  
>* HUOM: ravintolan tiedot löytyvät hieman epäsuorasti cachesta siinä vaiheessa kun ravintolan sivulle ollaan menossa. Jotta pääset tietoihin käsiksi on ravintolan id:n lisäksi "muistettava" kaupunki, josta ravintolaa etsittiin, tai edelliseksi tehdyn search-operaation tulos. Yksi tapa muistamiseen on käyttää sessiota, ks. https://github.com/mluukkai/WebPalvelinohjelmointi2014/blob/master/web/viikko3.md#k%C3%A4ytt%C3%A4j%C3%A4-ja-sessio
>
> Toinen tapa toiminnallisuuden toteuttamiseen on sivulla http://beermapping.com/api/reference/ oleva "Locquery Service"
>
> Kokeile hajottaako ravointoloiden sivun lisääminen mitään olemassaolevaa testiä. Jos, niin voit yrittää korjata testit. Välttämätöntä se ei kuitenkaan tässä vaiheessa ole.


Tehtävän jälkeen sovelluksesi voi näyttää esim. seuraavalta:

![kuva](https://github.com/mluukkai/WebPalvelinohjelmointi2014/raw/master/images/ratebeer-w5-2.png)


## Oluen reittaus suoraan oluen sivulta

Tällä hetkellä reittaukset luodaan erilliseltä sivulta, jolta reitattava olut valitaan erillisestä valikosta. Olisi luontevampaa, jos reittauksen voisi tehdä myös suoraan kunkin oluen sivulta.

Vaihtoehtoisia toteutustapoja on useita. Tutkitaan seuraavassa ehkä helpointa ratkaisua. Käytetään <code>form_for</code>-helperiä, eli luodaan lomake pohjalla olevaa olia hyödyntäen. **BeersControllerin** metodiin show tarvitaan pieni muutos:

```ruby
  def show
    @rating = Rating.new
    @rating.beer = @beer
  end
```

Eli siltä varalta, että oluelle tehdään reittaus, luodaan näykymätemplatea varten reittausolio, joka on jo liitetty tarkasteltavaan olioon. Reittausolio on luotu new:llä eli sitä ei siis ole talletettu kantaan, huomaa, että ennen metodin <code>show</code> suorittamista on suoritettu esifiltterin avulla määritelty komento, joka hakee kannasta tarkasteltavan oluen: <code>@beer = Beer.find(params[:id])</code>


Näkymätemplatea /views/beers/show.html.erb muutetaan seuraavasti:

```erb
<h2> <%= @beer %> </h2>

<p>
  <strong>Style:</strong>
  <%= @beer.style %>
</p>

<% if @beer.ratings.empty? %>
  <p>beer does not have yet been rated!</p>
<% else %>
  <p>has been rated <%= @beer.ratings.count %> times, average score <%= @beer.average_rating %></p>
<% end %>

<% if current_user %>

  <h4>give a rating:</h4>

  <%= form_for(@rating) do |f| %>
    <%= f.hidden_field :beer_id %>
    score: <%= f.number_field :score %>
    <%= f.submit %>
  <% end %>

  <%= link_to 'Edit', edit_beer_path(@beer) %>
    
<% end %>
```

Jotta lomake lähettäisi oluen id:n, tulee <code>beer_id</code>-kenttä lisätä lomakkeeseen. Emme kuitenkaan halua käyttäjän pystyvän manipuloimaan kenttää, joten kenttä on määritelty lomakkeelle <code>hidden_field</code>:iksi.

Koska lomake on luotu <code>form_for</code>-helperillä, tapahtuu sen lähettäminen automaattisesti HTTP POST -pyynnöllä <code>ratings_path</code>:iin eli reittauskontrollerin <code>create</code>-metodi käsittelee lomakkeen lähetyksen. Kontrolleri toimii ilman muutoksia! 

Ratkaisussa on pieni ongelma. Jos reittauksessa yritetään antaa epävalidi pistemäärä:

![kuva](https://github.com/mluukkai/WebPalvelinohjelmointi2014/raw/master/images/ratebeer-w5-3.png)

renderöi kontrolleri (eli reittauskontrollerin metodi <code>create</code>) oluen näkymän sijaan uuden reittauksen luomislomakkeen: 

![kuva](https://github.com/mluukkai/WebPalvelinohjelmointi2014/raw/master/images/ratebeer-w5-4.png)

Ongelman voisi kiertää katsomalla mistä osoitteesta create-metodiin on tultu ja renderöidä sitten oikea sivu riippuen tulo-osoitteesta. Emme kuitenkaan tee nyt tätä muutosta. 

Korjaamme ensin erään vielä vakavamman ongelman. Edellistä kahta kuvaa tarkastelemalla huomaamme että jos reittauksen (joka yritetään antaa oluelle _Huvila Pale Ale_) validointi epäonnistuu, ei tehty oluen valinta ole enää tallessa (valittuna on _iso 3_). 

Ongelman syynä on se, että pudotusvalikon vaihtoehdot generoivalle metodille <code>options_from_collection_for_select</code> ei ole kerrottu mikä vaihtoehdoista tulisi valita oletusarvoisesti, ja tälläisessä tilanteessa valituksi tulee kokoelman ensimmäinen olio. Oletusarvoinen valinta kerrotaan antamalla metodille neljäs parametri:

```erb
    options_from_collection_for_select(@beers, :id, :to_s, selected: @rating.beer_id) %>
```

Eli muutetaan näkymätemplate app/views/ratings/new.html.erb seuraavaan muotoon:

```erb
<h2>Create new rating</h2>

<%= form_for(@rating) do |f| %>
    <% if @rating.errors.any? %>
        <div id="error_explanation">
          <h2><%= pluralize(@rating.errors.count, "error") %> prohibited rating from being saved:</h2>

          <ul>
            <% @rating.errors.full_messages.each do |msg| %>
                <li><%= msg %></li>
            <% end %>
          </ul>
        </div>
    <% end %>

    <%= f.select :beer_id, options_from_collection_for_select(@beers, :id, :to_s, selected: @rating.beer_id) %>
    score: <%= f.number_field :score %>

    <%= f.submit %>
<% end %>
```

Sama ongelma itse asiassa vaivaa muutamia sovelluksemme lomakkeita, kokeile esim. mitä tapahtuu kun editoit oluen tietoja. Korjaa lomake jos haluat.

> ## Tehtävä 7
>
> Tee myös olutkerhoihin liitttyminen mahdolliseksi suoraan olutkerhon sivulta.
>
> Kannattaa noudattaa samaa toteutusperiaatetta kuin oluen sivulta tapahtuvassa reittaamisessa, eli lisää olutseuran sivulle lomake, jonka avulla voidaan luoda uusi <code>Membership</code>-olio, joka liittyy olutseuraan ja kirjautuneena olevaan käyttäjään. Lomakkeeseen ei tarvita muuta kuin 'submit'-painike: 
>
>```erb
>  <%= form_for(@membership) do |f| %>
>     <%= f.hidden_field :beer_club_id %>
>     <%= f.submit value:"join the club" %>
>  <% end %>
>```

Hienosäädetään olutseuraan liittymistä

> ## Tehtävä 8
>
> Tee ratkaisustasi sellainen, jossa liittymisnappia ei näytetä jos kukaan ei ole kirjautunut järjestelmään tai jos kirjautunut käyttäjä on jo seuran jäsen.
>
> Muokkaa koodiasi siten (membership-kontrollerin sopivaa metodia), että olutseuraan liittymisen jälkeen selain ohjautuu olutseuran sivulle ja sivu näyttää allaolevan kuvan mukaisen ilmoituksen uuden käyttäjän liittymisestä.

![kuva](https://github.com/mluukkai/WebPalvelinohjelmointi2014/raw/master/images/ratebeer-w5-5.png)

## Mielipanimoiden ja tyylin refaktorointi

__HUOM:__ tämä ja seuraava luku eivät sisällä jatkon kannalta oleellista uutta asiaa, rittää että luet luvut läpi.

Viime viikon tehtävissä 3 ja 4 (ks. https://github.com/mluukkai/WebPalvelinohjelmointi2014/blob/master/web/viikko4.md#teht%C3%A4v%C3%A4-3) toteutettiin metodit henkilön suosikkipanimon ja oluttyylin selvittämiseen. Seuraavassa on eräs suoraviivainen ratkaisu metodien <code>favorite_style</code> ja <code>favorite_brewery</code> toteuttamiseen:

```ruby
class User 
  # ...

  def favorite_brewery
    return nil if ratings.empty?
    brewery_ratings = rated_breweries.inject([]) { |set, brewery| set << [brewery, brewery_average(brewery) ] }
    brewery_ratings.sort_by{ |r| r.last }.last.first
  end

  def favorite_style
    return nil if ratings.empty?
    style_ratings = rated_styles.inject([]) { |set, style| set << [style, style_average(style) ] }
    style_ratings.sort_by{ |r| r.last }.last.first
  end

  private

  def rated_styles
    ratings.map{ |r| r.beer.style }.uniq
  end

  def style_average(style)
    ratings_of_style = ratings.select{ |r| r.beer.style==style }
    ratings_of_style.inject(0.0){ |sum, r| sum+r.score}/ratings_of_style.count
  end

  def rated_breweries
    ratings.map{ |r| r.beer.brewery}.uniq
  end

  def brewery_average(brewery)
    ratings_of_brewery = ratings.select{ |r| r.beer.brewery==brewery }
    ratings_of_brewery.inject(0.0){ |sum, r| sum+r.score}/ratings_of_brewery.count
  end
end  
```

Tutkitaan mielipanimon selvittävää metodia. Käytössä on kaksi apumetodia. Käyttäjän reittaamat panimot (eli panimot joilta käyttäjä on reitannut vähintään yhden oluen) saadaan selville seuraavasti (ks. http://www.google.com jos et tiedä map-komennon toimintaperiaatetta):

```ruby
  def rated_breweries
    ratings.map{ |r| r.beer.brewery}.uniq
  end
```

Toinen apumetodi selvittää tietyn panimon reittausten keskiarvon (huomaa komennot select ja inject, tarvittaessa katso http://www.google.com):

```ruby
  def brewery_average(brewery)
    ratings_of_brewery = ratings.select{ |r| r.beer.brewery==brewery }
    ratings_of_brewery.inject(0.0){ |sum, r| sum+r.score}/ratings_of_brewery.count
  end
```

Mielipanimon selvittävä metodi käy ensin läpi kaikki panimot ja selvittää jokaisen keskiarvoreittauksen. Tuloksena on taulukko muotoa <code>[[Koff, 10], [Stadinpanimo, 27], [Schlenkerla, 35], [Karjala, 18]]</code> (taulukossa ei ole oikeasti panimoiden nimiä vaan panimo-olioita). Taulukko järjestetään alkioiden jälkimmäisen parin (koodissa <code>r.last</code>) eli reittausten keskiarvon perusteella. Näin esimerkissämme <code>[Schlenkerla, 35]</code> menisi viimeiseksi. Metodi palauttaa järjestetyn taulukon viimeisen alkion ensimmäisen jäsenen, eli panimon, esimerkissä siis Schlenkerla-olion. 

```ruby
  def favorite_brewery
    return nil if ratings.empty?
    brewery_ratings = rated_breweries.inject([]) { |set, brewery| set << [brewery, brewery_average(brewery) ] }
    brewery_ratings.sort_by{ |r| r.last }.last.first
  end
```

Huomaamme, että <code>favorite_style</code> toimii täsmälleen saman periaatteen mukaan ja metodi itse sekä sen käyttämät apumetodit ovatkin oikeastaan copypastea mielipanimon selvittämiseen käytettävästä koodista. 

Koska ohjelmistossamme on kattavat testit, on copypaste helppo refaktoroida pois. Tutkitaan ensin apumetodeja:

```ruby
  def rated_styles
    ratings.map{ |r| r.beer.style }.uniq
  end

  def rated_breweries
    ratings.map{ |r| r.beer.brewery}.uniq
  end
```

Erona metodeissa on siis ainoastaan <code>map</code>-metodin koodilohkossa reittaukseen liittyvälle olut-oliolle kutsuttava metodi. Kutsuttava metodi voidaan antaa myös parametrina. Tällöin eksplisiittisen kutsun sijaan metodia kutsutaan olion <code>send</code>-metodin avulla:

```ruby
  def rated(category)
    ratings.map{ |r| r.beer.send(category) }.uniq
  end
```

Metodia voidaan nyt käyttää seuraavasti:

```ruby
irb(main):007:0> u = User.first
irb(main):008:0> u.rated :style
=> ["Lager", "Pale Ale"]
irb(main):009:0> u.rated :brewery
=> [#<Brewery id: 1, name: "Koff", year: 1897, created_at: "2014-01-30 18:14:44", updated_at: "2014-01-30 18:14:44">, #<Brewery id: 2, name: "Malmgard", year: 2001, created_at: "2014-01-30 18:14:44", updated_at: "2014-01-30 18:14:44">]
irb(main):010:0> 
```

Tehdään yhden tyylin tai panimon reittausten keskiarvon laskevasta metodista samaan tyyliin kategorian mukaan parametrisoitu:

```ruby
 def rating_average(category, item)
    ratings_of_item = ratings.select{ |r|r.beer.send(category)==item }
    return 0 if ratings_of_item.empty?
    ratings_of_item.inject(0.0){ |sum ,r| sum+r.score } / ratings_of_item.count
  end
```

Eli ensin etsitään reittaukset, jotka koskevat parametrina annettua panimoa tai oluttyyliä.
Sen jälkeen lasketaan normaaliin tapaan keskiarvo. 

Metodi toimii odotuksen mukaan:

```ruby
irb(main):012:0> u.rating_average(:style, "Lager")
=> 19.0
irb(main):013:0> 
```

Voimme nyt tehdä uusien apumetodien avulla helposti metodin, jonka avulla voi selvittää parametrista riippuen joko käyttäjän mielipanimon tai mielioluttyylin:

```ruby
  def favorite(category)
    return nil if ratings.empty?
    rating_pairs = rated(category).inject([]) do |pairs, item|
      pairs << [item, rating_average(category, item)]
    end
    rating_pairs.sort_by { |s| s.last }.last.first
  end
```

Kokeillaan konsolista:

```ruby
irb(main):015:0> u.favorite(:style)
=> "Pale Ale"
irb(main):016:0> u.favorite(:brewery)
=> #<Brewery id: 2, name: "Malmgard", year: 2001, created_at: "2014-01-30 18:14:44", updated_at: "2014-01-30 18:14:44">
irb(main):017:0> 
```

Mielityylin ja panimon selvittävät metodit voidaan sitten muuttaa delegoimaan toiminnalisuuden suorittaminen uudelle metodille:

```ruby
  def favorite_brewery
    favorite :brewery
  end

  def favorite_style
    favorite :style
  end
```

Uuden ratkaisumme etu on copypasten poiston lisäksi se, että jos oluelle määritellään jokun uusi "attribuutti", esim. väri, saamme samalla hinnalla mielivärin selvittävän metodin:

```ruby
  def favorite_color
    favorite :color
  end
```

## method_missing

__HUOM:__ tämä ja edellinen luku eivät sisällä  jatkon kannalta oleellista uutta asiaa, rittää että luet luvut läpi

Metodit <code>favorite_style</code> ja <code>favorite_brewery</code> olisi oikeastaan mahdollista saada toimimaan ilman niiden eksplisiittistä määrittelemistä. 

Kommentoidaan metodit hetkeksi pois koodistamme.

Jos oliolle kutsutaan metodia, jota ei ole olemassa (määriteltynä luokassa itsessään, sen yliluokissa eikä missään luokan tai yliluokkien sisällyttämässä moduulissa), esim. 

```ruby
irb(main):018:0> u = User.first
irb(main):019:0> u.paras_bisse
NoMethodError: undefined method `paras_bisse' for #<User:0x007fb5bd02d698>
	from /Users/mluukkai/.rbenv/versions/2.0.0-p247/lib/ruby/gems/2.0.0/gems/activemodel-4.0.2/lib/active_model/attribute_methods.rb:439:in `method_missing'
	from /Users/mluukkai/.rbenv/versions/2.0.0-p247/lib/ruby/gems/2.0.0/gems/activerecord-4.0.2/lib/active_record/attribute_methods.rb:155:in `method_missing'
	from (irb):19
	from /Users/mluukkai/.rbenv/versions/2.0.0-p247/lib/ruby/gems/2.0.0/gems/railties-4.0.2/lib/rails/commands/console.rb:90:in `start'
	from /Users/mluukkai/.rbenv/versions/2.0.0-p247/lib/ruby/gems/2.0.0/gems/railties-4.0.2/lib/rails/commands/console.rb:9:in `start'
	from /Users/mluukkai/.rbenv/versions/2.0.0-p247/lib/ruby/gems/2.0.0/gems/railties-4.0.2/lib/rails/commands.rb:62:in `<top (required)>'
	from bin/rails:4:in `require'
	from bin/rails:4:in `<main>'
irb(main):020:0> 
```

on tästä seurauksena se, että Ruby-tulkki kutsuu olion <code>method_missing</code>-metodia parametrinaan tuntemattoman metodin nimi. Rubyssä kaikki luokat perivät <code>Object</code>-luokan, joka määrittelee <code>method_missing</code>-metodin. Luokkien on sitten tarvittaessa mahdollista ylikirjoittaa tämä metodi ja saada näinollen aikaan "metodeita" joita ei ole olemassa, mutta jotka kutsujan kannalta toimivat aivan kuten normaalit metodit. 

Rails käyttää sisäisesti metodia <code>method_missing</code> moniin tarkoituksiin. Emme voikaan suoraviivaisesti ylikirjoittaa sitä, meidän on muistettava delegoida <code>method_missing</code>-kutsut yliluokalle jollemme halua käsitellä niitä itse.

Määritellään luokalle <code>User</code> kokeeksi seuraavanlainen <code>method_missing</code>:

```ruby
  def method_missing(method_name, *args, &block)
    puts "nonexisting method #{method_name} was called with parameters: #{args}"
    return super
  end
```

kokeillaan:

```ruby
irb(main):023:0> u.paras_bisse
nonexisting method paras_bisse was called with parameters: []
NoMethodError: undefined method `paras_bisse' for #<User:0x007fb5b9592470>
	from /Users/mluukkai/.rbenv/versions/2.0.0-p247/lib/ruby/gems/2.0.0/gems/activemodel-4.0.2/lib/active_model/attribute_methods.rb:439:in `method_missing'
	from /Users/mluukkai/.rbenv/versions/2.0.0-p247/lib/ruby/gems/2.0.0/gems/activerecord-4.0.2/lib/active_record/attribute_methods.rb:155:in `method_missing'
	from /Users/mluukkai/kurssirepot/wadror/ratebeer/app/models/user.rb:34:in `method_missing'
	from (irb):23
	from /Users/mluukkai/.rbenv/versions/2.0.0-p247/lib/ruby/gems/2.0.0/gems/railties-4.0.2/lib/rails/commands/console.rb:90:in `start'
	from /Users/mluukkai/.rbenv/versions/2.0.0-p247/lib/ruby/gems/2.0.0/gems/railties-4.0.2/lib/rails/commands/console.rb:9:in `start'
	from /Users/mluukkai/.rbenv/versions/2.0.0-p247/lib/ruby/gems/2.0.0/gems/railties-4.0.2/lib/rails/commands.rb:62:in `<top (required)>'
	from bin/rails:4:in `require'
	from bin/rails:4:in `<main>'
irb(main):024:0> 
```

Eli kuten ylimmältä riviltä huomataan, suoritettiin määrittelemämme <code>method_missing</code>-metodi. Voimmekin ylikirjoittaa method_missingin seuraavasti:

```ruby
  def method_missing(method_name, *args, &block)
    if method_name =~ /^favorite_/
      category = method_name[9..-1].to_sym
      self.favorite category
    else
      return super
    end
  end
```

Nyt kaikki <code>favorite_</code>-alkuiset metodikutsut joita ei tunneta tulkitaan siten, että alaviivan jälkeinen osa eristetään ja kutsutaan oliolle metodia <code>favorite</code>, siten että alaviivan jälkiosa on kategorian määrittelevänä parametrina. 

Nyt metodit <code>favorite_brewery</code> ja <code>favorite_style</code> "ovat olemassa" ja toimivat:

```ruby
irb(main):030:0> u = User.first
irb(main):031:0> u.favorite_style
=> "Pale Ale"
irb(main):032:0> u.favorite_brewery
=> #<Brewery id: 2, name: "Malmgard", year: 2001, created_at: "2014-01-30 18:14:44", updated_at: "2014-01-30 18:14:44">
irb(main):033:0> 
```

Ikävänä sivuvaikutuksena metodien määrittelystä method_missing:in avulla  on se, että mikä tahansa favorite_-alkuinen metodi "toimisi", mutta aiheuttaisi kenties epäoptimaalisen virheen.

```ruby
irb(main):033:0> u.favorite_movie
NoMethodError: undefined method `movie' for #<Beer:0x007fb5bd03d610>
```

Ruby tarjoaa erilaisia mahdollisuuksia mm. sen määrittelemiseen, mitkä <code>favorite_</code>-alkuiset metodit hyväksyttäisiin. Voisimme esim. toteuttaa seuraavan rubymäisen tavan asian määrittelemiselle:

```ruby
class User < ActiveRecord::Base
  include RatingAverage

  favorite_available_by :style, :brewery

  # ...
end
```

Emme kuitenkaan lähde nyt tälle tielle. Hyöty tulisi näkyviin vasta jos favorite_-alkuisia metodeja voitaisiin hyödyntää muissakin luokissa.

Poistetaan kuitenkin nyt tässä tekemämme method_missing:iin perustuva toteutus ja palautetaan luvun alussa poiskommentoidut versiot.

Jos tässä luvussa esitellyn tyyliset temput kiinnostavat, voit jatkaa esim. seuraavista:

* http://rubymonk.com/learning/books/5-metaprogramming-ruby-ascent
* http://rubymonk.com/learning/books/2-metaprogramming-ruby
* https://github.com/sathish316/metaprogramming_koans
* myös kirja [Eloquent Ruby](http://www.amazon.com/Eloquent-Ruby-Addison-Wesley-Professional-Series/dp/0321584104) käsittelee aihepiiriä varsin hyvin 

## Migraatioista

Olemme käyttäneet Railsin migraatioita jo ensimmäisestä viikosta alkaen. On aika syventyä aihepiiriin hieman tarkemmin.

> ## Tehtävä 9
>
> Lue ajatuksella http://guides.rubyonrails.org/migrations.html

## Oluttyyli

> ## Tehtävät 10-12 (vastaa kolmea tehtävää)
>
> Laajenna sovellustasi siten, että oluttyyli ei ole enää merkkijono, vaan tyylit on talletettu tietokantaan. Jokaiseen oluttyyliin liittyy myös tekstuaalinen kuvaus. Tyylin kuvauksen tyypiksi kannattaa määritellä <code>text</code>, tyypin <code>string</code> avulla määritellyn sarakkeen oletuskoko on nimittäin vain 255 merkkiä.
>
> Muutoksen jälkeen oluen ja tyylin suhteen tulee olla seuraava

![kuva](http://yuml.me/30b291af)

> Huomaa, oluella nyt oleva attribuutti <code>style</code> tulee poistaa, jotta ei synnyt ristiriitaa assosiaation ansiosta generoitavan aksessorin ja vanhan kentän välille.
> 
> Saattaa olla hieman haasteellista suorittaa muutos siten, että oluet linkitetään automaattisesti oikeisiin  tyylitietokannan tauluihin.
> Tämäkin onnistuu, jos teet muutoksen useassa askeleessa, esim:
> * luo tietokantataulu tyyleille
> * tee tauluun rivi jokaista _beers_-taulusta löytyvää erinimistä tyyliä kohti (tämä onnistuu konsolista käsin)
> * uudelleennimeä _beers_-taulun sarake style esim. _old_style_:ksi (tämä siis migraation avulla)
> * liitä konsolista käsin oluet _style_-olioihin käyttäen hyväksi oluilla vielä olevaa old_style-saraketta
> * tuhoa oluiden taulusta migraation avulla _old_style_
>
> Huomaa, että heroku-instanssin ajantasaistaminen kannattaa tehdä samalla!
>
> Voit myös suorittaa siirtymisen uusiin tietokannassa oleviin tyyleihin suoraviivaisemmin eli poistamalla oluilta _style_-sarakkeen ja asettamalla oluiden tyylit esim. konsolista.
>
> Muutoksen jälkeen uutta olutta luotaessa oluen tyyli valitaan panimoiden tapaan valmiilta listalta. Lisää myös tyylien sivulle vievä linkki navigaatiopalkkiin.
>
> Tyylien sivulle kannattaa lisätä lista kaikista tyylin oluista.

Tehtävän jälkeen oluttyylin sivu voi näyttää esim. seuraavalta

![kuva](https://github.com/mluukkai/WebPalvelinohjelmointi2014/raw/master/images/ratebeer-w5-6.png)

**HUOM:** varmista, että uusien oluiden luominen toimii vielä laajennuksen jälkeen!

Hyvä lista oluttyyleistä kuvauksineen löytyy osoitteesta http://beeradvocate.com/beer/style/

> ## Tehtävä 13
>
> Tyylien tallettaminen tietokantaan hajottaa suuren osan  testeistä. Ajantasaista testit. Huomaa, että myös FactoryGirlin tehtaisiin on tehtävä muutoksia.
> 
> Vaikka hajonneita testejä on suuri määrä, älä mene paniikkiin. Selvitä ongelmat testi testiltä, yksittäinen ongelma kertautuu monteen paikkaan ja testien ajantasaistaminen ei ole loppujenlopuksi kovin vaikeaa.

## Rails-sovellusten tietoturvasta

Emme ole vielä toistaiseksi puhuneet mitään Rails-sovellusten tietoturvasta. Nyt on aika puuttua asiaan. Rails-guideissa on tarjolla erinomainen katsaus tyypillisimmistä web-sovellusten tietoturvauhista ja siitä miten Rails-sovelluksissa voi uhkiin varautua.

> ## Tehtävät 14-15
>
> Lue http://guides.rubyonrails.org/security.html 
>
> Teksti on pitkä mutta asia on tärkeä. Jos haluat optimoida ajankäyttöä, jätä luvut 4, 5 ja 7.4-7.8 lukematta.
>
> Voit merkata tehtävät tehdyksi kun seuraavat asiat selvillä
> * SQL-injektio
> * CSRF
> * XSS
> * järkevä sessioiden käyttö 
>
> Tietoturvaan liittyen kannattaa katsoa myös seuraavat
> * http://guides.rubyonrails.org/action_controller_overview.html#force-https-protocol
> * http://guides.rubyonrails.org/action_controller_overview.html#log-filtering

Yo. dokumentista ei käy täysin selväksi se, että Rails _sanitoi_ (eli escapettaa kaikki script- ja html-tagit yms) oletusarvoisesti sivuilla renderöitävän syötteen, eli esim. jos yrittäisimme syöttää javascript-pätkän <code><script>alert('Evil XSS attack');</script></code> oluttyylin kuvaukseen, koodia ei suoriteta, vaan koodi renderöityy sivulle 'tekstinä': 

![kuva](https://github.com/mluukkai/WebPalvelinohjelmointi2014/raw/master/images/ratebeer-w5-7.png)

Jos katsomme sivun lähdekoodia, huomaamme, että Rails on korvannut HTML-tägit aloittavat ja sulkevat < -ja > -merkit niitä vastaavilla tulostuvilla merkeillä, jolloin syöte muuttuu selaimen kannalta normaaliksi tekstiksi:

```ruby
 &lt;script&gt;alert(&#39;Evil XSS attack&#39;);&lt;/script&gt;
```

Oletusarvoisen sanitoinnin saa 'kytkettyä pois' pyytämällä eksplisiittisesti metodin <code>raw</code> avulla, että renderöitävä sisältö sijoitetaan sivulle sellaisenaan. Jos muuttaisimme tyylin kuvauksen renderöintiä seuraavasti

```ruby
<p>
  <%= raw(@style.description) %>
</p>
```

suoritetaan javascript-koodi sivun renderöinnion yhteydessä:

wadror2![kuva](https://github.com/mluukkai/WebPalvelinohjelmointi2014/raw/master/images/ratebeer-w5-8.png)

Lisätietoa http://www.railsdispatch.com/posts/security ja http://railscasts.com/episodes/204-xss-protection-in-rails-3


## Sovelluksen ulkoasun hienosäätö

Viimeviikon tapaan voit halutessasi tehdä hienosäätöä sovelluksen näkymiin, viikolla 6 tehtävät asiat eivät juurikaan ole riippuvaisia näkymien detaljeista.


## Tehtävien palautus

Commitoi kaikki tekemäsi muutokset ja pushaa koodi Githubiin. Deployaa myös uusin versio Herokuun.

Tehtävät kirjataan palautetuksi osoitteeseen http://wadrorstats2014.herokuapp.com/

Tehtävien palauttaminen on mahdollista vasta 10.2.

