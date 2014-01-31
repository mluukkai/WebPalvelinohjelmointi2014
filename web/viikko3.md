Jatkamme sovelluksen rakentamista siitä, mihin jäimme viikon 2 lopussa. Allaoleva materiaali olettaa, että olet tehnyt kaikki edellisen viikon tehtävät. Jos et tehnyt kaikkia tehtäviä, voit ottaa kurssin repositorioista [edellisen viikon mallivastauksen](https://github.com/mluukkai/WebPalvelinohjelmointi2014/tree/master/malliv/viikko2). Jos sait suurimman osan edellisen viikon tehtävistä tehtyä, saattaa olla helpointa, että täydennät vastaustasi mallivastauksen avulla.

Jos otat edellisen viikon mallivastauksen tämän viikon pohjaksi, kopioi hakemisto pois kurssirepositorion alta (olettaen että olet kloonannut sen) ja tee sovelluksen sisältämästä hakemistosta uusi repositorio.

**Huom:** muutamilla Macin käyttäjillä oli ongelmia Herokun tarvitseman pg-gemin kanssa. Paikallisesti gemiä ei tarvita ja se määriteltiinkin asennettavaksi ainoastaan tuotantoympäristöön. Jos ongelmia ilmenee, voit asentaa gemit antamalla <code>bundle install</code>-komentoon seuraavan lisämääreen:

    bundle install --without production

Tämä asetus muistetaan jatkossa, joten pelkkä `bundle install` riittää kun haluat asentaa uusia riippuvuuksia.

## Muutamia selvennyksiä

Tutkitaan hetki luokkaa <code>Brewery</code>:

```ruby
class Brewery < ActiveRecord::Base
  include RatingAverage

  has_many :beers, dependent: :destroy
  has_many :ratings, through: :beers
end
```

Panimoilla on nimi <code>name</code> ja perustamisvuosi <code>year</code>. Konsolista käsin pääsemme tuttuun tyyliin näihin käsiksi:

```ruby
irb(main):001:0> b = Brewery.first
irb(main):002:0> b.name
=> "Koff"
irb(main):003:0> b.year
=> 1897
irb(main):004:0> 
```

Teknisesti ottaen esim. <code>b.year</code> on metodikutsu. Rails luo model-olioon jokaiselle vastaavan tietokantataulun skeeman määrittelemälle sarakkeelle kentän eli attribuutin ja metodit attribuutin arvon lukemista ja arvon muuttamista varten. Nämä automaattisesti generoidut metodit ovat sisällöltään suunilleen seuraavat:

```ruby
class Brewery < ActiveRecord::Base
  # ..

  def year
    read_attribute(:year)
  end
  
  def year=(value)
    write_attribute(:year, value)
  end
end  
```

Metodit siis mahdollistavat olion attribuutin arvon lukemisen ja muuttamisen. Arvoa muuttava metodi ei siis vielä tee muutosta tietokantaan, muutos tapahtuu vasta kutsuttaessa metodia <code>save</code>, kyseessä ovatkin siis automaattisesti generoituvat 'getterit ja setterit'.

Olion ulkopuolelta olion attribuutteihin päästään siis käsiksi 'pistenotaatiolla':
    
    b.year

entä olion sisältä? Tehdään panimolle metodi, joka demonstroi panimon attribuuttien käsittelyä panimon sisältä:

```ruby
class Brewery < ActiveRecord::Base
  include RatingAverage

  has_many :beers, dependent: :destroy
  has_many :ratings, through: :beers

  def print_report
    puts name
    puts "established at year #{year}"
    puts "number of beers #{beers.count}"
    puts "number of ratings #{ratings.count}"
  end
end
```
eli olion sisältä metodeja (myös <code>beers</code> ja <code>ratings</code> ovat metodeja!) voi kutsua kuten esim. javassa, metodin nimellä.

Ja esimerkki metodin käytöstä:

```ruby
irb(main):001:0> b = Brewery.first
irb(main):002:0> b.print_report
Koff
established at year 1897
number of beers 2
number of ratings 8
```

Metodeja olisi voitu kutsua olion sisältä myös käyttäen Rubyn 'thissiä' eli olion <code>self</code>-viitettä:

```ruby
  def print_report
    puts self.name
    puts "established at year #{self.year}"
    puts "number of beers #{self.beers.count}"
    puts "number of ratings #{self.ratings.count}"
  end
```

Tehdään sitten panimolle metodi, jonka avulla panimon voi 'uudelleenkäynnistää', tällöin panimon perustamisvuosi muuttuu vuodeksi 2014:

```ruby
  def restart
    year = 2014
    puts "changed year to #{year}"
  end
```

kokeillaan

```ruby
irb(main):024:0> b = Brewery.first
irb(main):025:0> b.year
=> 1897
irb(main):026:0> b.restart
changed year to 2014
=> nil
irb(main):027:0> b.year
=> 1897
irb(main):028:0> 
```

eli huomaamme, että vuoden muuttaminen ei toimikaan odotetulla tavalla! Syynä tähän on se, että <code>year = 2014</code> metodin <code>restart</code> sisällä ei kutsukaan metodia

    def year=(value)
    
joka sijoittaisi attribuutille uuden arvon, vaan luo metodille paikallisen muuttujan nimeltään <code>year</code> johon arvo 2014 sijoitetaan. 

Jotta sijoitus onnistuu, on metodia kutsuttava <code>self</code>-viitteen kautta:

```ruby
  def restart
    self.year = 2014
    puts "changed year to #{year}"
  end
```
ja nyt toiminnallisuus on odotetun kaltainen:

```ruby
irb(main):029:0> b = Brewery.first
irb(main):030:0> b.year
=> 1897
irb(main):031:0> b.restart
changed year to 2014
=> nil
irb(main):032:0> b.year
=> 2014
irb(main):033:0>  
```  

**HUOM:** Rubyssä olioiden instanssimuuttujat määritellään <code>@</code>-alkuisina. Instanssimuuttujat _eivät_ kuitenkaan ole sama asia kuin ActiveRecordin avulla tietokantaan talletettavat olioiden  attribuutit. Eli seuraavakaan metodi ei toimisi odotetulla tavalla:

```ruby
  def restart
    @year = 2014
    puts "changed year to #{@year}"
  end
```

Panimon sisällä <code>self.year</code> siis on ActiveRecordin tietokantaan tallentama attribuutti, kun taas <code>@year</code> on olion instanssimuuttuja. Railsin modeleissa instanssimuuttuujia ei juurikaan käytetä. Instanssimuuttujia käytetään Railsissa lähinnä tiedonvälitykseen kontrollereilta näkymille.

## Käyttäjä ja sessio

Laajennetaan sovellusta seuraavaksi siten, että käyttäjien on mahdollista rekisteröidä itselleen järjestelmään käyttäjätunnus. 
Tulemme hetken päästä muuttamaan toiminnallisuutta myös siten, että jokainen reittaus liittyy sovellukseen kirjautuneena olevaan käyttäjään:

![mvc-kuva](http://yuml.me/ddc9b7c9)

Tehdään käyttäjä ensin pelkän käyttäjätunnuksen omaavaksi olioksi ja lisätään myöhemmin käyttäjälle myös salasana.

Luodaan käyttäjää varten malli, näkymä ja kontrolleri komennolla <code>rails g scaffold user username:string</code>

Uuden käyttäjän luominen tapahtuu Rails-konvention mukaan osoitteessa <code>users/new</code> olevalla lomakkeella. Olisi kuitenkin luontevampaa jos osoite olisi <code>signup</code>. Lisätään routes.rb:hen vaihtoehtoinen reitti

    get 'signup', to: 'users#new'

eli myös osoitteeseen signup tuleva HTTP GET -pyyntö käsitellään Users-kontrollerin metodin <code>new</code> avulla.

HTTP on tilaton protokolla, eli kaikki HTTP-protokollalla suoritetut pyynnöt ovat toisistaan riippumattomia. Jos Web-sovellukseen kuitenkin halutaan toteuttaa tila, esim. käyttäjän kirjautuminen, tulee jonkinlainen tieto websession "tilasta" välittää jollain tavalla jokaisen selaimen tekemän HTTP-kutsun mukana. Yleisin tapa 
tilatiedon välittämiseen ovat evästeet, ks. http://en.wikipedia.org/wiki/HTTP_cookie

Lyhyesti sanottuna evästeiden toimintaperiaate on seuraava: kun selaimella mennään jollekin sivustolle, voi palvelin lähettää vastauksessa selaimelle pyynnön evästeen tallettamisesta. Jatkossa selain liittää evästeen kaikkiin sivustolle kohdistuneisiin HTTP-pyyntöihin. Eväste on käytännössä pieni määrä dataa, ja palvelin voi käyttää evästeessä olevaa dataa haluamallaan tavalla evästeen omaavan selaimen tunnistamiseen.

Railsissa sovelluskehittäjän ei ole tarvetta työskennellä suoraan evästeiden kanssa, sillä Railsiin on toteutettu evästeiden avulla hieman korkeammalla abstratkiotasolla toimivat __sessiot__ ks.
http://guides.rubyonrails.org/action_controller_overview.html#session joiden avulla sovellus voi "muistaa" tiettyyn selaimeen liittyviä asioita, esim. käyttäjän identiteetin, useiden HTTP-pyyntöjen ajan. 

Kokeillaan ensin sessioiden käyttöä muistamaan käyttäjän viimeksi tekemä reittaus. Rails-sovelluksen koodissa HTTP-pyynnön tehneen käyttäjän (tai tarkemmin ottaen selaimen) sessioon pääsee käsiksi hashin kaltaisesti toimivan olion <code>session</code> kautta. 

Talletetaan reittaus sessioon tekemällä seuraava lisäys reittauskontrolleriin:

```ruby
  def create
    rating = Rating.create params.require(:rating).permit(:score, :beer_id)

    # talletetaan tehdyn reittauksen sessioon 
    session[:last_rating] = "#{rating.beer.name} #{rating.score} points"

    redirect_to ratings_path
  end
```

jotta  edellinen reittaus saadaan näkyviin kaikille sivuille, lisätään application layoutiin (eli tiedostoon app/views/layouts/application.html.erb) seuraava:

```erb
<% if session[:last_rating].nil? %>
  <p>no ratings given</p>
<% else %>
  <p>previous rating: <%= session[:last_rating] %></p>
<% end %>
```

Kokeillaan nyt sovellusta. Aluksi sessioon ei ole talletettu mitään ja <code>session[:last_rating]</code> on arvoltaan <code>nil</code> eli sivulla pitäisi lukea "no ratings given". Tehdään reittaus ja näemme että se tallentuu sessioon. Tehdään vielä uusi reittaus ja havaitsemme että se ylikirjoittaa sessiossa olevan tiedon.

Avaa nyt sovellus incognito-ikkunaan tai toisella selaimella. Huomaat, että toisessa selaimessa session arvo on <code>nil</code>. Eli sessio on selainkohtainen. 

## Kirjautuminen

Ideana on toteuttaa kirjautuminen siten, että kirjautumisen yhteydessä talletetaan sessioon kirjautuvaa käyttäjää vastaavan <code>User</code>-olion </code>id</code>. Uloskirjautuessa sessio nollataan.

Huom: sessioon voi periaatteessa tallennella melkein mitä tahansa olioita, esim. kirjautunutta käyttäjää vastaava <code>User</code>-olio voitaisiin myös tallettaa sessioon. Hyvänä käytänteenä (ks. http://guides.rubyonrails.org/security.html#session-guidelines) on kuitenkin tallettaa sessioon mahdollisimman vähän tietoa (oletusarvoisesti Railsin sessioihin voidaan tallentaa korkeintaan 4kB tietoa), esim. juuri sen verran, että voidaan identifioida kirjautunut käyttäjä, johon liittyvät muut tiedot saadaan tarvittaessa haettua tietokannasta.

Tehdään nyt sovellukseen kirjautumisesta ja uloskirjautumisesta huolehtiva kontrolleri. Usein Railsissa on tapana noudattaa myös kirjautumisen toteuttamisessa RESTful-ideaa ja konvention mukaisia polkunimiä. 

Voidaan ajatella, että kirjautumisen yhteydessä syntyy sessio, ja tätä voidaan pitää jossain mielessä samanlaisena "resurssina" kuin esim. olutta. Nimetäänkin kirjautumisesta huolehtiva kontrolleri <code>SessionsController</code>iksi ja luodaan sille routes.rb:hen seuraavat reitit

    resources :sessions, only: [:new, :create]

eli kirjautumissivun osoite on **sessions/new**. Osoitteeseen **sessions** tehty POST-kutsu suorittaa kirjautumisen. Uloskirjautumisen reitistä huolehdimme vasta myöhemmin.

Tehdään kontrolleri. Kontrolleriin olemme tehneet myös uloskirjautumisesta huolehtivan kontrollerimetodin vaikka ulkoskirjautuminen ei ole vielä HTTP:n avulla mahdollista:

```ruby
class SessionsController < ApplicationController
    def new
      # renderöi kirjautumissivun
    end

    def create
      # haetaan usernamea vastaava käyttäjä tietokannasta
      user = User.find_by username: params[:username]
      # talletetaan sessioon kirjautuneen käyttäjän id (jos käyttäjä on olemassa)
      session[:user_id] = user.id if not user.nil?
      # uudelleen ohjataan käyttäjä omalle sivulleen 
      redirect_to user   
    end

    def destroy
      # nollataan sessio
      session[:user_id] = nil
      # uudelleenohjataan sovellus pääsivulle 
      redirect_to :root
    end
end
```


Kirjautumissivun app/views/sessions/new.html.erb koodi on seuraavassa:

```erb
<h1>Sign in</h1>

<%= form_tag sessions_path do %>
  <%= text_field_tag :username, params[:username] %>
  <%= submit_tag "Log in" %>
<% end %>
```

Toisin kuin reittauksille tekemämme formi (kertaa asia [viime viikolta](https://github.com/mluukkai/WebPalvelinohjelmointi2014/blob/master/web/viikko2.md#lomake-ja-post)), nyt tekemämme lomake ei perustu olioon ja lomake luodaan <code>form_tag</code>-metodilla, ks. http://guides.rubyonrails.org/form_helpers.html#dealing-with-basic-forms

Lomakkeen lähettäminen siis aiheuttaa HTTP POST -pyynnön sessions_pathiin eli osoitteeseen **sessions**. Pyynnön käsittelevä metodi ottaa <code>params</code>-olioon talletetun käyttäjätunnuksen ja hakee sitä vastaavan käyttäjäolion kannasta ja tallettaa olion id:n sessioon jos olio on olemassa. Lopuksi käyttäjä uudelleenohjataan omalle sivulleen. Kontrollerin koodi vielä uudelleen seuraavassa:

```ruby
    def create
      user = User.find_by username: params[:username]
      session[:user_id] = user.id if not user.nil?
      redirect_to user
    end
```

Huom1: komento <code>redirect_to user</code> siis on lyhennysmerkintä seuraavalla <code>redirect_to user_path(user)</code>, ks. [viikko 1](https://github.com/mluukkai/WebPalvelinohjelmointi2014/blob/master/web/viikko1.md#kertausta-polkujen-ja-kontrollerien-niment%C3%A4konventiot). 

Huom2: Rubyssa yhdistelmän <code>if not</code> sijaan voidaan käyttää myös komentoa <code>unless</code>, eli metodin toinen rivi oltaisiin voitu kirjoittaa muodossa

```ruby
  session[:user_id] = user.id unless user.nil?
```

Lisätään application layoutiin seuraava koodi, joka lisää kirjautuneen käyttäjän nimen kaikille sivuille (edellisessä luvussa lisätyt sessioharjoittelukoodit voi samalla poistaa):

```erb
<% if not session[:user_id].nil? %>
  <p><%= User.find(session[:user_id]).username %> signed in</p>
<% end %>
```

menemällä osoitteeseen http://localhost:3000/sessions/new voimme nyt kirjautua sovellukseen. Uloskirjautuminen ei vielä toistaiseksi onnistu.

> ## Tehtävä 1
>
> Tee kaikki ylläesitetyt muutokset ja varmista, että kirjautuminen onnistuu (eli kirjautunut käyttäjä näytetään sivulla) olemassaolevalla käyttäjätunnuksella (jonka siis voit luoda osoitteessa http://localhost:3000/signup). Vaikka uloskirjautuminen ei ole mahdollista, voit kirjautua uudella tunnuksella kirjautumisosoitteessa ja vanha kirjautuminen ylikirjoittuu.

## Kontrollerien ja näyttöjen apumetodi

Tietokantakyselyn tekeminen näytön koodissa (kuten juuri teimme application layoutiin lisätyssä koodissa) on todella ruma tapa. Lisätään luokkaan <code>ApplicationController</code> seuraava metodi:

```ruby
class ApplicationController < ActionController::Base
  protect_from_forgery
  
  # määritellään, että metodi current_user tulee käyttöön myös näkymissä
  helper_method :current_user

  def current_user
    return nil if session[:user_id].nil? 
    User.find(session[:user_id]) 
  end
end
```

Koska kaikki sovelluksen kontrollerit perivät luokan <code>ApplicationController</code>, on määrittelemämme metodi kaikkien kontrollereiden käytössä. Määrittelimme lisäksi metodin <code>current_user</code> ns. helper-metodiksi, joten se tulee kontrollerien lisäksi myös kaikkien näkymien käyttöön. Voimme nyt muuttaa application layoutiin lisätyn koodin seuraavaan muotoon:

```erb
<% if not current_user.nil? %>
  <p><%= current_user.username %> signed in</p>
<% end %>
```

Kirjautumisen osoite __sessions/new__ on hieman ikävä. Määritellänkin kirjautumista varten luontevampi vaihtoehtoinen osoite __signin__. Määritellään myös reitti ulkoskirjautumiselle. Lisätään siis seuraavat routes.rb:hen:

```ruby
  get 'signin', to: 'sessions#new'
  delete 'signout', to: 'sessions#destroy'
```

eli kirjautumislomake on nyt osoitteessa http://localhost:3000/signin ja ulkoskirjautuminen tapahtuu osoitteeseen _signout_ tehtävän HTTP DELETE -pyynnön avulla.

Olisi periaatteessa ollut mahdollista määritellä myös

```ruby
  get 'signout', to: 'sessions#destroy'
```
eli mahdollistaa uloskirjautuminen HTTP GET:in avulla. Ei kuitenkaan pidetä hyvänä käytänteenä, että HTTP GET -pyyntö tekee muutoksia sovelluksen tilaan ja pysyttäydytään edelleen REST-filosofian mukaisessa käytänteessä, jonka mukaan resurssin tuhoaminen tapahtuu HTTP DELETE -pyynnöllä. Tässä tapauksessa vaan resurssi on hieman laveammin tulkittava asia eli käyttäjän sisäänkirjautuminen.

> ## Tehtävä 2
>
> Muokkaa nyt sovelluksen application layoutissa olevaa navigaatiopalkkia siten, että palkkiin tulee näkyville sisään- ja uloskirjautumislinkit. Huomioi, että uloskirjautumislinkin yhteydessä on määriteltävä käytettäväksi HTTP-metodiksi delete, katso esimerkki tähän esim. kaikki käyttäjät listaavalta sivulta. 
>
> Edellisten lisäksi lisää palkkiin linkki kaikkien käyttäjien sivulle, sekä kirjautuneen käyttäjän nimi, joka toimii linkkinä käyttäjän omalle sivulle. Käyttäjän ollessa kirjaantuneena tulee palkissa olla myös linkki uuden oluen reittaukseen.

Tehtävän jälkeen sovelluksesi näyttää suunilleen seuraavalta jos käyttäjä on kirjautuneena:
    
![kuva](https://github.com/mluukkai/WebPalvelinohjelmointi2014/raw/master/images/ratebeer-w3-1.png)


ja seuraavalta jos käyttäjä ei ole kirjautuneena (huomaa, että nyt näkyvillä on myös uuden käyttäjän rekisteröitymiseen tarkoitettu signup-linkki):

![kuva](https://github.com/mluukkai/WebPalvelinohjelmointi2014/raw/master/images/ratebeer-w3-2.png)

## Reittaukset käyttäjälle

Muutetaan seuraavaksi sovellusta siten, että reittaus kuuluu kirjautuneena olevalle käyttäjälle, eli tämän vaiheen jälkeen olioiden suhteen tulisi näyttää seuraavalta:

![kuva](http://yuml.me/ccdb3938)

Modelien tasolla muutos kulkee tuttuja latuja:

```ruby
class User < ActiveRecord::Base
  has_many :ratings   # käyttäjällä on monta ratingia
end

class Rating < ActiveRecord::Base
  belongs_to :beer
  belongs_to :user   # rating kuuluu myös käyttäjään

  def to_s
    "#{beer.name} #{score}"
  end
end
```

Ratkaisu ei kuitenkaan tällaisenaan toimi. Yhteyden takia _ratings_-tietokantatauluun riveille tarvitaan vierasavaimeksi viite käyttäjän id:hen. Railsissa kaikki muutokset tietokantaan tehdään Ruby-koodia olevien migraatioiden avulla. Luodaan nyt uuden sarakkeen lisäävä migraatio. Generoidaan ensin migraatiotiedosto komentoriviltä komennolla:

    rails g migration AddRatingsForeignKeyToUser

Hakemistoon _db/migrate_ ilmestyy tiedosto, jonka sisältö on seuraava

```ruby
class AddRatingsForeignKeyToUser < ActiveRecord::Migration
  def change
  end
end
```

Huomaa, että hakemistossa on jo omat migraatiotiedostot kaikkia luotuja tietokantatauluja varten. Jokaiseen migraatioon sisällytetään tieto sekä tietokantaan tehtävästä muutoksesta että muutoksen mahdollisesta perumisesta. Jos migraatio on riittävän yksinkertainen, eli sellainen että Rails osaa päätellä suoritettavasta lisäyksestä myös sen peruvan operaation, riittää että migraatiossa on määriteltynä ainoastaan metodi <code>change</code>. Jos migraatio on monimutkaisempi, on määriteltävä metodit <code>up</code> ja <code>down</code> jotka määrittelevät erikseen migraation tekemisen ja sen perumisen. 

Tällä kertaa tarvittava migraatio on yksinkertainen:

```ruby
class AddRatingsForeignKeyToUser < ActiveRecord::Migration
  def change
    add_column :ratings, :user_id, :integer
  end
end
```
 
Jotta migraation määrittelemä muutos tapahtuu, suoritetaan komentoriviltä tuttu komento <code>rake db:migrate</code>

Migraatiot ovat varsin laaja aihe ja harjoittelemme niitä vielä lisää myöhemmin kurssilla. Lisää migraatiosta löytyy osoitteesta http://guides.rubyonrails.org/migrations.html

Huomaamme nyt konsolista, että yhteys olioiden välillä toimii:

```ruby
irb(main):001:0> u = User.first
irb(main):002:0> u.ratings
=> #<ActiveRecord::Associations::CollectionProxy []>
irb(main):003:0> 
```

Toistaiseksi antamamme reittaukset eivät liity mihinkään käyttäjään:

```ruby
irb(main):005:0> r = Rating.first
irb(main):006:0> r.user
=> nil
```

Päätetään että laitetaan kaikkien olemassaolevien reittausten käyttäjäksi järjestelmään ensimmäisenä luotu käyttäjä:

```ruby
irb(main):010:0> u = User.first
irb(main):011:0> Rating.all.each{ |r| u.ratings << r }
irb(main):012:0> u.ratings.count
=> 18
irb(main):013:0> 
```

**HUOM:** reittausten tekeminen käyttöliittymän kautta ei toistaiseksi toimi kunnolla, sillä näin luotuja uusia reittauksia ei vielä liitetä mihinkään käyttäjään. Korjaamme tilanteen pian.

> ## Tehtävä 3
>
>  Lisää käyttäjän sivulle eli näkymään app/views/users/show.html.erb
> * käyttäjän reittausten määrä ja keskiarvo (huom: käytä edellisellä viikolla  määriteltyä moduulia <code>RatingAverage</code>, jotta saat keskiarvon laskevan koodin käyttäjälle!)
> * lista käyttäjän reittauksista ja mahdollisuus poistaa reittauksia 

Käyttäjän sivu siis näyttää suunilleen seuraavalta (**HUOM:** sivulle olisi pitänyt lisätä myös tieto käyttäjän antamien reittausten keskiarvosta mutta se unohtui...):

![kuva](https://github.com/mluukkai/WebPalvelinohjelmointi2014/raw/master/images/ratebeer-w3-3.png)

Reittauksen poisto vie nyt kaikkien reittausten sivulle. Luontevinta olisi, että poiston jälkeen palattaisiin takaisin käyttäjän sivulle. Tee seuraava muutos reittauskontrolleriin, jotta näin tapahtuisi:

```ruby
  def destroy
    rating = Rating.find(params[:id])
    rating.delete
    redirect_to :back
  end
```

Eli kuten arvata saattaa, <code>redirect_to :back</code> aiheuttaa uudelleenohjauksen takaisin siihen osoitteeseen, jolta HTTP DELETE -pyynnön aiheuttama linkin klikkaus suoritettiin.

Uusien reittausten luominen www-sivulta ei siis tällä hetkellä toimi, koska reittaukseen ei tällä hetkellä liitetä kirjautuneena olevaa käyttäjää. Muokataan siis  reittauskontrolleria siten, että kirjautuneena oleva käyttäjä linkitetään luotavaan reittaukseen:

```ruby
  def create
    rating = Rating.create params.require(:rating).permit(:score, :beer_id)
    current_user.ratings << rating
    redirect_to current_user
  end
```

Huomaa, että <code>current_user</code> on luokkaan <code>ApplicationController</code> äsken lisäämämme metodi, joka palauttaa kirjautuneena olevan käyttäjän eli suorittaa koodin:

```ruby
  User.find(session[:user_id]) 
```

Reittauksen luomisen jälkeen kontrolleri on laitettu uudelleenohjaamaan selain kirjautuneena olevan käyttäjän sivulle.

> ## Tehtävä 4
>
> Muuta sovellusta vielä siten, että kaikkien reittausten sivulla ei ole enää mahdollisuutta reittausten poistoon ja että reittauksen yhteydessä näkyy reittauksen tekijän nimi, joka myös toimii linkkinä reittaajan sivulle. 

Kaikkien reittausten sivun tulisi siis näyttää edellisen tehtävän jälkeen seuraavalta:

![kuva](https://github.com/mluukkai/WebPalvelinohjelmointi2014/raw/master/images/ratebeer-w3-4.png)

## Kirjautumisen hienosäätöä

Tällä hetkellä sovellus käyttäytyy ikävästi, jos kirjautumista yritetään olemassaolemattomalla käyttäjänimellä. Uudelleenohjataan käyttäjä takaisin kirjautumissivulle, jos kirjautuminen epäonnistuu. Eli muutetaan sessiokontrolleria seuraavasti:

```ruby
    def create
      user = User.find_by username: params[:username]
      if user.nil? 
        redirect_to :back
      else
        session[:user_id] = user.id 
        redirect_to user
      end
    end
```

muutetaan edellistä vielä siten, että lisätään käyttäjälle kirjautumisen epäonnistuessa, sekä onnistuessa näytettävät viestit:

```ruby
    def create
      user = User.find_by username: params[:username]
      if user.nil?
        redirect_to :back, notice: "User #{params[:username]} does not exist!"
      else
        session[:user_id] = user.id
        redirect_to user, notice: "Welcome back!"
      end
    end
```

Jotta viesti saadaan näkyville kirjautumissivulle, lisätään näkymään ```app/views/sessions/new.html.erb``` seuraava elementti:

```erb
<p id="notice"><%= notice %></p>
```

Elementti on jo valmiina käyttäjän sivun templatessa (ellet vahingossa poistanut sitä), joten viesti toimii siellä.

Sivulla tarvittaessa näytettävät, seuraavaan HTTP-pyyntöön muistettavat eli uudelleenohjauksenkin yhteydessä toimivat viestit eli __flashit__ on toteutettu Railssissa sessioiden avulla, ks. lisää http://guides.rubyonrails.org/action_controller_overview.html#the-flash

## Olioiden kenttien validointi

Sovelluksessamme on tällä hetkellä pieni ongelma: on mahdollista luoda useita käyttäjiä, joilla on sama käyttäjätunnus. User-kontrollerin metodissa <code>create</code> pitäisi siis tarkastaa, ettei <code>username</code> ole jo käytössä.

Railsiin on sisäänrakennettu monipuolinen mekanismi olioiden kenttien validointiin, ks http://guides.rubyonrails.org/active_record_validations.html ja http://apidock.com/rails/ActiveModel/Validations/ClassMethods

Käyttäjätunnuksen yksikäsitteisyyden validointi onkin helppoa, pieni lisäys User-luokkaan riittää:

```ruby
class User < ActiveRecord::Base
  include RatingAverage

  validates :username, uniqueness: true

  has_many :ratings
end
```

Jos nyt yritetään luoda uudelleen jo olemassaoleva käyttäjä, huomataan että Rails osaa generoida sopivan virheilmoituksen automaattisesti. 

Rails (tarkemmin sanoen ActiveRecord) suorittaa oliolle määritellyt validoinnit juuri ennen kuin olio yritetään tallettaa tietokantaan esim. operaatioiden <code>create</code> tai <code>save</code> yhteydessä. Jos validointi epäonnistuu, olioa ei tallenneta.

Lisätään saman tien muitakin validointeja sovellukseemme. Lisätään käyttäjälle vaatimus, että käyttäjätunnuksen pituuden on oltava vähintään 3 merkkiä, eli lisätään User-luokkaan rivi:

```ruby
  validates :username, length: { minimum: 3 }
```

samaa attribuuttia koskevat validointisäännöt voidaan myös yhdistää, yhden <code>validates :attribuutti</code> -kutsun alle:

```ruby
class User < ActiveRecord::Base
  include RatingAverage

  validates :username, uniqueness: true,
                       length: { minimum: 3 }

  has_many :ratings
end
```

Railsin scaffold-generaattorilla luodut kontrollerit toimivat siis siten, että jos validointi onnistuu ja olio on tallentunut kantaan, uudelleenohjataan selain luodun olion sivulle. Jos taas validointi epäonnistuu, näytetään uudelleen olion luomisesta huolehtiva lomake ja renderöidään virheilmoitukset lomakkeen näyttävälle sivulle. 

Mistä kontrolleri tietää, että validointi on epäonnistunut? Validointi siis tapahtuu tietokantaan talletuksen yhteydessä. Jos kontrolleri tallettaa olion metodilla <code>save</code>, voi kontrolleri testata metodin paluuarvosta onko validointi onnistunut:

```ruby
  @user = User.new(parametrit)
  if @user.save
  	# validointi onnistui, uudelleenohjaa selain halutulle sivulle
  else
    # validointi epäonnistui, renderöi näkymätemplate :new
  end
```

Scaffoldin generoima kontrolleri näyttää hieman monimutkaisemmalta:


```ruby
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render action: 'show', status: :created, location: @user }
      else
        format.html { render action: 'new' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end
```

Ensinnäkin mistä tulee olion luonnissa parametrina käytettävä <code>user_params</code>? Huomaamme, että tiedoston alalaitaan on määritelty metodi

```ruby
    def user_params
      params.require(:user).permit(:username)
    end
```

eli metodin <code>create</code> ensimmäinen rivi on siis sama kuin

```ruby
   @user = User.new(params.require(:user).permit(:username))
```

Entä mitä metodin päättävä <code>respond_to</code> tekee? Jos olion luonti tapahtuu normaalin lomakkeen kautta, eli selain odottaa takaisin HTML-muotoista vastausta, on toiminnallisuus oleellisesti seuraava:

```ruby
 if @user.save
  redirect_to @user, notice: 'User was successfully created.'          
 else
   render action: 'new' 
 end
```

eli suoritetaan komentoon (joka on oikeastaan metodi) <code>respond_to</code> liittyvässä koodilohkossa merkintään (joka on jälleen teknisesti ottaen metodikutsu) <code>format.html</code> liittyvä koodilohko. Jos taas käyttäjä-olion luova HTTP POST -kutsu olisi tehty siten, että vastausta odotettaisiin json-muodossa (näin tapahtuisi esim. jos pyyntö tehtäisiin toisesta palvelusta tai Web-sivulta javascriptillä), suoritettaisiin <code>format.json</code>:n liittyvä koodi. Syntaksi saattaa näyttää aluksi oudolta, mutta siihen tottuu pian. 

Jatketaan sitten validointien parissa. Määritellään että oluen reittauksen tulee olla kokonaisluku väliltä 1-50:

```ruby
class Rating < ActiveRecord::Base
  belongs_to :beer
  belongs_to :user

  validates :score, numericality: { greater_than_or_equal_to: 1,
                                    less_than_or_equal_to: 50,
                                    only_integer: true }
                                      
   # ...
end
```

Jos luomme nyt virheellisen reittauksen, ei se talletu kantaan. Huomamme kuitenkin, että emme saa virheilmoitusta. Ongelmana on se, että loimme lomakkeen käsin ja se ei sisällä scaffoldingin yhteydessä automaattisesti generoituvien lomakkeiden tapaan virheraportointia ja että kontrolleri ei tarkista millään tavalla validoinnin onnistumista.

Muutetaan ensin reittaus-kontrollerin metodia <code>create</code> siten, että validoinnin epäonnistuessa se renderöi uudelleen reittauksen luomisesta huolehtivan lomakkeen:

```ruby
  def create
    @rating = Rating.new params.require(:rating).permit(:score, :beer_id)

    if @rating.save
      current_user.ratings << @rating
      redirect_to user_path current_user
    else
      @beers = Beer.all
      render :new
    end
  end
```

Metodissa luodaan siis ensin Rating-olio <code>new</code>:llä, eli sitä ei vielä talleteta tietokantaan. Tämän jälkeen suoritetaan tietokantaan tallennus metodilla <code>save</code>. Jos tallennuksen yhteydessä suoritettava olion validointi epäonnistuu, metodi palauttaa epätoden, ja olio ei tallennu kantaan. Tällöin renderöidään new-näkymätemplate. Näkymätemplaten renderöinti edellyttää, että oluiden lista on talletettu muuttujaan <code>@beers</code>.

Kun nyt yritämme luoda virheellisen reittauksen, käyttäjä pysyy lomakkeen näyttävässä näkymässä (joka siis teknisesti ottaen renderöidään uudelleen POST-kutsun jälkeen). Virheilmoituksia ei kuitenkaan vielä näy.

Validoinnin epäonnistuessa Railsin validaattori tallettaa virheilmoitukset <code>@ratings</code> olion kenttään <code>@rating.errors</code>. 

Muutetaan lomaketta siten, että lomake näyttää kentän <code>@rating.errors</code> arvon, jos kenttään on asetettu jotain:

```erb
<h2>Create new rating</h2>

<%= form_for(@rating) do |f| %>
  <% if @rating.errors.any? %>
  	<%= @rating.errors.inspect %>
  <% end %>

  <%= f.select :beer_id, options_from_collection_for_select(@beers, :id, :to_s) %>
  score: <%= f.number_field :score %>
  <%= f.submit %>

<% end %>
```

Kun nyt luot virheellisen reittauksen, huomaat että virheen syy selviää kenttään <code>@rating.errors</code> talletetusta oliosta.

Otetaan sitten mallia esim. näkymätemplatesta views/users/_form.html.erb ja muokataan lomakettamme (views/ratings/new.html.erb) seuraavasti:

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

  <%= f.select :beer_id, options_from_collection_for_select(@beers, :id, :to_s) %>
  score: <%= f.number_field :score %>
  <%= f.submit %>

<% end %>
```

Validointivirheitä löytyessä, näkymätemplate renderöi nyt kaikki joukossa <code>@rating.errors.full_messages</code> olevat virheilmoitukset.

**Huom:** validoinnin epäonnistuessa ei siis suoriteta uudelleenohjausta (miksi se ei tässä tapauksessa toimi?), vaan renderöidään näkymätemplate, johon tavallisesti päädytään <code>new</code>-metodin suorituksen yhteydessä.

Apuja seuraaviin tehtäviin löytyy osoitteesta
http://guides.rubyonrails.org/active_record_validations.html ja http://apidock.com/rails/ActiveModel/Validations/ClassMethods

> ## Tehtävä 5
>
> Lisää ohjelmaasi seuraavat validoinnit
> * oluen ja panimon nimi on epätyhjä
> * panimon perustamisvuosi on kokonaisluku väliltä 1042-2014
> * käyttäjätunnuksen eli User-luokan attribuutin username pituus on vähintään 3 mutta enintään 15 merkkiä

> ## Tehtävä 6 
>
> ### tehtävän teko ei ole viikon jatkamisen kannalta välttämätöntä eli ei kannata juuttua tähän tehtävään. Voit tehdä tehtävän myös viikon muiden tehtävien jälkeen.
>
> Parannellaan tehtävän 5 validointia siten, että panimon perustamisvuoden täytyy olla kokonaisluku, jonka suuruus on vähintään 1042 ja korkeintaan menossa oleva vuosi. Vuosilukua ei siis saa kovakoodata.
>
> Huomaa, että seuraava ei toimi halutulla tavalla:
>
>   validates :year, numericality: { less_than_or_equal_to: Time.now.year }
>
> Nyt käy siten, että <code>Time.now.year</code> evaluoidaan siinä vaiheessa kun ohjelma lataa luokan koodin. Jos esim. ohjelma käynnistetään vuoden 2014 lopussa, ei vuoden 2015 alussa voida rekisteröidä 2015 aloittanutta panimoa, sillä vuoden yläraja validoinnissa on ohjelman käynnistyshetkellä evaluoitunut 2014
>
> Eräs kelvollinen ratkaisutapa on oman validointimetodin määritteleminen http://guides.rubyonrails.org/active_record_validations.html#custom-methods
>
> Koodimäärällisesti lyhyempiäkin ratkaisuja löytyy, vihjeenä olkoon lambda/Proc/whatever...


## Monen suhde moneen -yhteydet

Yhteen olueeseen liittyy monta reittausta, ja reittaus liittyy aina yhteen käyttäjään, eli olueeseen liittyy monta reittauksen tehnyttä käyttäjää. Vastaavasti käyttäjällä on monta reittausta ja reittaus liittyy yhteen olueeseen. Eli käyttäjään liittyy monta reitattua olutta. Oluiden ja käyttäjien välillä on siis **monen suhde moneen -yhteys**, jossa ratings-taulu toimii liitostaulun tavoin.

Saammekin tuotua tämän many to many -yhteyden kooditasolle helposti käyttämällä jo [edellisen viikon lopulta tuttua](https://github.com/mluukkai/WebPalvelinohjelmointi2014/blob/master/web/viikko2.md#olioiden-ep%C3%A4suora-yhteys) tapaa, eli **has_many through** -yhteyttä:

```ruby
class Beer < ActiveRecord::Base
  include RatingAverage

  belongs_to :brewery
  has_many :ratings, dependent: :destroy
  has_many :users, through: :ratings

  # ...
end

class User < ActiveRecord::Base
  include RatingAverage

  has_many :ratings
  has_many :beers, through: :ratings

  # ...
end
``` 

Ja monen suhde moneen -yhteys toimii käyttäjästä päin:

```ruby
irb(main):003:0> u = User.first
irb(main):004:0> u.beers
=> #<ActiveRecord::Associations::CollectionProxy [#<Beer id: 1, name: "Iso 3", style: "Lager", brewery_id: 1, created_at: "2014-01-06 21:07:15", updated_at: "2014-01-06 21:07:15">, #<Beer id: 1, name: "Iso 3", style: "Lager", brewery_id: 1, created_at: "2014-01-06 21:07:15", updated_at: "2014-01-06 21:07:15">,  ...]>
irb(main):005:0> u.beers
```

ja oluesta päin:

```ruby
irb(main):008:0> b = Beer.first
irb(main):009:0> b.users
=> #<ActiveRecord::Associations::CollectionProxy [#<User id: 1, username: "mluukkai", created_at: "2014-01-21 22:37:36", updated_at: "2014-01-21 22:37:36">, #<User id: 1, username: "mluukkai", created_at: "2014-01-21 22:37:36", updated_at: "2014-01-21 22:37:36">, #<User id: 1, username: "mluukkai", created_at: "2014-01-21 22:37:36", updated_at: "2014-01-21 22:37:36">, #<User id: 1, username: "mluukkai", created_at: "2014-01-21 22:37:36", updated_at: "2014-01-21 22:37:36">, #<User id: 1, username: "mluukkai", created_at: "2014-01-21 22:37:36", updated_at: "2014-01-21 22:37:36">, #<User id: 1, username: "mluukkai", created_at: "2014-01-21 22:37:36", updated_at: "2014-01-21 22:37:36">]>
irb(main):010:0> 
```

Vaikuttaa ihan toimivalta, mutta tuntuu hieman kömpeltä viitata oluen reitanneisiin käyttäjiin nimellä <code>users</code>. Luontevampi viittaustapa oluen reitanneisiin käyttäjiin olisi kenties <code>raters</code>. Tämä onnistuu vaihtamalla yhteyden määrittelyä seuraavasti

```ruby
has_many :raters, through: :ratings, source: :user
```

Oletusarvoisesti <code>has_many</code> etsii liitettävää taulun nimeä ensimmäisen parametrinsa nimen perusteella. Koska <code>raters</code> ei ole nyt yhteyden kohteen nimi, on se määritelty erikseen _source_-option avulla.

Yhteytemme uusi nimi toimii:

```ruby
irb(main):011:0> b = Beer.first
irb(main):012:0> b.raters
=> #<ActiveRecord::Associations::CollectionProxy [#<User id: 1, username: "mluukkai", created_at: "2014-01-21 22:37:36", updated_at: "2014-01-21 22:37:36">, #<User id: 1, username: "mluukkai", created_at: "2014-01-21 22:37:36", updated_at: "2014-01-21 22:37:36">, #<User id: 1, username: "mluukkai", created_at: "2014-01-21 22:37:36", updated_at: "2014-01-21 22:37:36">, #<User id: 1, username: "mluukkai", created_at: "2014-01-21 22:37:36", updated_at: "2014-01-21 22:37:36">, #<User id: 1, username: "mluukkai", created_at: "2014-01-21 22:37:36", updated_at: "2014-01-21 22:37:36">, #<User id: 1, username: "mluukkai", created_at: "2014-01-21 22:37:36", updated_at: "2014-01-21 22:37:36">]>
irb(main):013:0> 
```

Koska sama käyttäjä voi tehdä useita reittauksia samasta oluesta, näkyy käyttäjä useaan kertaan oluen reittaajien joukossa. Jos haluamme yhden reittaajan näkymään ainoastaan kertaalleen, onnistuu tämä esim. seuraavasti: 

```ruby
irb(main):013:0> b.raters.uniq
=> [#<User id: 1, username: "mluukkai", created_at: "2014-01-21 22:37:36", updated_at: "2014-01-21 22:37:36">]
irb(main):014:0> 
```

Olisi mahdollista myös määritellä, että oluen <code>raters</code> palauttaisi oletusarvoisesti vain kertaalleen yksittäisen käyttäjän. Tämä onnistuisi asettamalla <code>has_many</code>-määreelle __scope__, joka rajoittaa niiden olioiden joukkoa, jotka näytetään assosiaatioon liittyviksi:

```ruby
class Beer < ActiveRecord::Base
  #…

  has_many :raters, -> { uniq }, through: :ratings, source: :user

  #…
end
```

Lisää asiaa yhteyksien määrittelemisestä normaaleissa ja hieman monimutkaisemmissa tapauksissa löytyy sivulta http://guides.rubyonrails.org/association_basics.html

Huom: Railsissa on myös toinen tapa many to many -yhteyksien luomiseen <code>has_and_belongs_to_many</code> ks. http://guides.rubyonrails.org/association_basics.html#the-has-and-belongs-to-many-association jonka käyttö saattaa tulla kyseeseen jos liitostaulua ei tarvita mihinkään muuhun kuin yhteyden muodostamiseen.

Trendinä kuitenkin on, että metodin has_and_belongs_to_many sijaan käytetään (sen monien ongelmien takia)  has_many through -yhdistelmää ja eksplisiittisesti määriteltyä yhteystaulua. Mm. Chad Fowler kehottaa kirjassaan [Rails recepies](http://pragprog.com/book/rr2/rails-recipes) välttämään has_and_belongs_to_many:n käyttöä, sama neuvo annetaan Obie Fernandezin autoritiivisessa teoksessa [Rails 4 Way](https://leanpub.com/tr4w)

> ## Tehtävät 7-8: Olutseurat
>
> ### Tämän ja seuraavan tehtävän tekeminen ei ole välttämätöntä viikon jatkamisen kannalta. Voit tehdä tämän tehtävän myös viikon muiden tehtävien jälkeen.
>
> Laajennetaan järjestelmää siten, että käyttäjillä on mahdollista olla eri _olutseurojen_ jäseninä.
>
> Luo scaffoldingia hyväksikäyttäen model <code>BeerClub</code>, jolla on attribuutit <code>name</code> (merkkijono) <code>founded</code> (kokonaisluku) ja <code>city</code> (merkkijono) 
>
> Muodosta <code>BeerClub</code>in ja <code>User</code>ien välille monen suhde moneen -yhteys. Luo tätä varten liitostauluksi model <code>Membership</code>, jolla on attribuutteina vierasavaimet <code>User</code>- ja <code>BeerClub</code>-olioihin (eli <code>beer_club_id</code> ja <code>user_id</code>, huomaa miten iso kirjain olion keskellä muuttuu alaviivaksi!). Tämänkin modelin voit luoda scaffoldingilla.
> 
> Voit toteuttaa tässä vaiheessa jäsenien liittämisen olutseuroihin esim. samalla tavalla kuten oluiden reittaus tapahtuu tällä hetkellä, eli lisäämällä navigointipalkkiin linkin "join a club", jonka avulla kirjautunut käyttäjä voidaan littää johonkin listalla näytettävistä olutseuroista.  
>
> Listaa olutseuran sivulla kaikki jäsenet ja vastaavasti henkilöiden sivulla kaikki olutseurat, joiden jäsen henkilö on. Lisää navigointipalkkiin linkki kaikkien olutseurojen listalle.
>
> Tässä vaiheessa ei ole vielä tarvetta toteuttaa toiminnallisuutta, jonka avulla käyttäjän voi poistaa olutseurasta.

> # Tehtävä 9
>
> Hio edellisessä tehävässä toteuttamaasi toiminnallisuutta siten, että käyttäjä ei voi liittyä useampaan kertaan samaan olutseuraan.

Seuraavat kaksi kuvaa antavat suuntaviivoja sille miltä sovelluksesi voi näyttää tehtävien 7-9 jälkeen.

![kuva](https://github.com/mluukkai/WebPalvelinohjelmointi2014/raw/master/images/ratebeer-w3-5.png)

![kuva](https://github.com/mluukkai/WebPalvelinohjelmointi2014/raw/master/images/ratebeer-w3-6.png)

## Salasana

Muutetaan sovellusta vielä siten, että käyttäjillä on myös salasana. Tietoturvasyistä salasanaa ei kannata tallentaa tietokantaan. Kantaan talletetaan ainoastaan salasanasta yhdensuuntaisella funktiolla laskettu tiiviste. Tehdään tätä varten migraatio:

    rails g migration AddPasswordDigestToUser

migraation (ks. hakemisto db/migrate) koodiksi tulee seuraava:

```ruby
class AddPasswordDigestToUser < ActiveRecord::Migration
  def change
    add_column :users, :password_digest, :string
  end
end
```

huomaa, että lisättävän sarakkeen nimen on oltava <code>password_digest</code>. 

Tehdään seuraava lisäys luokkaan <code>User</code>:

```ruby
class User < ActiveRecord::Base
  include RatingAverage

  has_secure_password

  # ...
end
```

<code>has_secure_password</code> (ks. http://api.rubyonrails.org/classes/ActiveModel/SecurePassword/ClassMethods.html) lisää luokalle toiminnallisuuden, jonka avulla salasanan _tiiviste_ talletetaan kantaan ja käyttäjä voidaan tarpeen vaatiessa autentikoida. 

Rails käyttää tiivisteen tallettamiseen <code>bcrypt-ruby</code> gemiä. Otetaan se käyttöön lisäämällä Gemfile:en rivi

    gem 'bcrypt-ruby', '~> 3.1.2'

Tämän jälkeen annetaan komentoriviltä komento <code>bundle install</code> jotta gem asentuu.

Kokeillaan nyt hieman uutta toiminnallisuutta konsolista (joudut uudelleenkäynnistämään konsolin, jotta se saa käyttöönsä uuden gemin). 

Salasanatoiminnallisuus <code>has_secure_password</code> lisää oliolle  attribuutit <code>password</code> ja <code>password_confirmation</code>. Ideana on, että salasana ja se varmistettuna sijoitetaan näihin attribuutteihin. Kun olio talletetaan tietokantaan esim. metodin <code>save</code> kutsun yhteydessä, lasketaan tiiviste ja se tallettuu tietokantaan olion sarakkeen <code>password_digest</code> arvoksi. Selväkielinen salasana eli attribuutti <code>password</code> ei siis tallennu tietokantaan, vaan on ainoastaan olion muistissa olevassa representaatiossa.


Talletetaan käyttäjälle salasana:

```ruby
irb(main):011:0> u = User.first
irb(main):012:0> u.password = "salainen"
irb(main):013:0> u.password_confirmation = "salainen"
irb(main):014:0> u.save
irb(main):015:0> u
=> #<User id: 1, username: "mluukkai", created_at: "2014-01-21 22:37:36", updated_at: "2014-01-23 16:14:55", password_digest: "$2a$10$vlNYRqULpGAVpXBYMHcKCeYNRVhLEVaPdlQxwXmpIIO7...">
```

Jos komento <code>u.password = "salainen"</code> saa aikaan virheilmoituksen <code>NoMethodError: undefined method `password_digest=' for ...</code>, suorita komentoriviltä <code>rake db:migrate</code>.

Autentikointi tapahtuu <code>User</code>-olioille lisätyn metodin <code>authenticate</code> avulla seuraavasti:

```ruby
irb(main):016:0> u.authenticate "salainen"
=> #<User id: 1, username: "mluukkai", created_at: "2014-01-21 22:37:36", updated_at: "2014-01-23 16:14:55", password_digest: "$2a$10$vlNYRqULpGAVpXBYMHcKCeYNRVhLEVaPdlQxwXmpIIO7...">
irb(main):017:0> u.authenticate "virhe"
=> false
irb(main):018:0> 
```

eli metodi <code>authenticate</code> palauttaa <code>false</code>, jos sille parametrina annettu salasana on väärä. Jos salasana on oikea, palauttaa metodi olion itsensä.

Lisätään nyt kirjautumiseen salasanan tarkistus. Muutetaan ensin kirjautumissivua (app/views/sessions/new.html.erb) siten että käyttäjätunnuksen lisäksi pyydetään salasanaa (huomaa että lomakkeen kentän tyyppi on nyt *password_field*, joka näyttää kirjoitetun salasanan sijasta ruudulla ainoastaan tähtiä):

```erb
<h1>Sign in</h1>

<p id="notice"><%= notice %></p>

<%= form_tag sessions_path do %>
  username <%= text_field_tag :username, params[:username] %>
  password <%= password_field_tag :password, params[:password] %>
  <%= submit_tag "Log in" %>
<% end %>
```

ja muutetaan sessions-kontrolleria siten, että se varmistaa metodia <code>authenticate</code> käyttäen, että lomakkeelta on annettu oikea salasana.

```ruby
    def create
      user = User.find_by username: params[:username]
      if user.nil? or not user.authenticate params[:password]
        redirect_to :back, notice: "username and password do not match"
      else
        session[:user_id] = user.id
        redirect_to user_path(user), notice: "Welcome back!"
      end
    end
```

Kokeillaan toimiiko kirjautuminen (**huom: jotta bcrypt-gem tulisi sovelluksen käyttöön, käynnistä rails server uudelleen**). Kirjautuminen onnistuu toistaiseksi vain niiden käyttäjien tunnuksilla joihin olet lisännyt salasanan konsolista käsin.

Lisätään vielä uuden käyttäjän luomiseen (eli näkymään view/users/_form.html.erb) salasanan syöttökenttä:

```erb
  <div class="field">
    <%= f.label :password %><br />
    <%= f.password_field :password %>
  </div>
  <div class="field">
    <%= f.label :password_confirmation %><br />
    <%= f.password_field :password_confirmation  %>
  </div>
```

Käyttäjien luomisesta huolehtivan kontrollerin apumetodia <code>user_params</code> on myös muutettava siten, että lomakkeelta lähetettyyn salasanaan ja sen varmenteeseen päästään käsiksi:

```erb
 def user_params
     params.require(:user).permit(:username, :password, :password_confirmation)
  end
```

Kokeile mitä tapahtuu, jos password confirmatioksi annetaan eri arvo kuin passwordiksi.

> ## Tehtävä 10
> 
> Tee luokalle User-validointi, joka varmistaa, että salasanan pituus on vähintää 4 merkkiä, ja että salasana sisältää vähintään yhden ison kirjaimen (voit unohtaa skandit) ja yhden numeron.


## Vain omien reittausten poisto

Tällä hetkellä kuka tahansa voi poistaa kenen tahansa reittauksia. Muutetaan sovellusta siten, että käyttäjä voi poistaa ainoastaan omia reittauksiaan. Tämä onnistuu helposti tarkastamalla asia reittauskontrollerissa:

```ruby
  def destroy
    rating = Rating.find params[:id]
    rating.delete if current_user == rating.user
    redirect_to :back
  end
```

eli tehdään poisto-operaatio ainoastaan, jos ```current_user``` on sama kuin reittaukseen liittyvä käyttäjä.

Reittauksen poistolinkkiä ei oikeastaan ole edes syytä näyttää muuta kuin kirjaantuneen käyttäjän omalla sivulla. Eli muutetaan käyttäjän show-sivua seuraavasti:

```erb
  <ul>
    <% @user.ratings.each do |rating| %>
      <li> 
        <%= rating %> 
        <% if @user == current_user %>
            <%= link_to 'delete', rating, method: :delete, data: { confirm: 'Are you sure?' } %> 
        <% end %>
      </li>
    <% end %>
  </ul>
```

Huomaa, että pelkkä **delete**-linkin poistaminen ei estä poistamasta muiden käyttäjien tekemiä reittauksia, sillä on erittäin helppoa tehdä HTTP DELETE -operaatio mielivaltaisen reittauksen urliin. Tämän takia on oleellista tehdä kirjaantuneen käyttäjän tarkistus poistamisen suorittavassa kontrollerimetodissa.

> ## Tehtävä 11
>
> Kaikkien käyttäjien listalla http://localhost:3000/users on nyt linkki **destroy**, jonka avulla käyttäjän voi tuhota, sekä linkki **edit** käyttäjän tietojen muuttamista varten. Poista molemmat linkit sivulta ja lisää ne (oikeastaan deleten siirto riittää, sillä edit on jo valmiina) käyttäjän sivulle. 
>
> Näytä editointi- ja tuhoamislinkki vain kirjautuneen käyttäjän itsensä sivulla. Muuta myös User-kontrollerin metodeja <code>update</code> ja <code>destroy</code> siten, että olion tietojen muutosta tai poistoa ei voi tehdä kuin kirjaantuneena oleva käyttäjä itselleen.

> ## Tehtävä 12
> 
> Luo uusi käyttäjätunnus, kirjaudu käyttäjänä ja tuhoa käyttäjä. Käyttäjätunnuksen tuhoamisesta seuraa ikävä virhe. **Pääset virheestä eroon tuhoamalla selaimesta cookiet.** Mieti mistä virhe johtuu ja korjaa asia myös sovelluksesta siten, että käyttäjän tuhoamisen jälkeen sovellus ei joudu virhetilanteeseen. 

> ## Tehtävä 13
>
> Laajenna vielä sovellusta siten, että käyttäjän tuhoutuessa käyttäjän tekemät reittaukset tuhoutuvat automaattisesti. Ks. https://github.com/mluukkai/WebPalvelinohjelmointi2014/blob/master/web/viikko2.md#orvot-oliot
>
> Jos teit tehtävät 7-8 eli toteutit järjestelmään olutkerhot, tuhoa käyttäjän tuhoamisen yhteydessä myös käyttäjän jäsenyydet olutkerhoissa



## Lisää hienosäätöä

Käyttäjän editointitoiminto mahdollistaa nyt myös käyttäjän <code>username</code>:n muuttamisen. Tämä ei ole ollenkaan järkevää. Poistetaan tämä mahdollisuus. 

Uuden käyttäjän luominen ja käyttäjän editoiminen käyttävät molemmat samaa, tiedostossa views/users/_form.html.erb määriteltyä lomaketta. Alaviivalla alkavat näkymätemplatet ovat Railsissa ns. partiaaleja, joita liitetään muihin templateihin <code>render</code>-kutsun avulla. 

Käyttäjän editointiin tarkoitettu näkymätemplate on seuraavassa:

```erb
<h1>Editing user</h1>

<%= render 'form' %>

<%= link_to 'Show', @user %> |
<%= link_to 'Back', users_path %>
```

eli ensin se renderöi _form-templatessa olevat elementit ja sen jälkeen pari linkkiä. Lomakkeen koodi on seuraava:

```erb
<%= form_for(@user) do |f| %>
  <% if @user.errors.any? %>
    <div id="error_explanation">
      <h2><%= pluralize(@user.errors.count, "error") %> prohibited this user from being saved:</h2>

      <ul>
      <% @user.errors.full_messages.each do |msg| %>
        <li><%= msg %></li>
      <% end %>
      </ul>
    </div>
  <% end %>

  <div class="field">
    <%= f.label :username %><br>
    <%= f.text_field :username %>
  </div>
  <div class="field">
    <%= f.label :password %><br />
    <%= f.password_field :password %>
  </div>
  <div class="field">
    <%= f.label :password_confirmation %><br />
    <%= f.password_field :password_confirmation  %>
  </div>

  <div class="actions">
    <%= f.submit %>
  </div>
<% end %>

```

Haluaisimme siis poistaa lomakkeesta seuraavat

```erb
  <div class="field">
    <%= f.label :username %><br>
    <%= f.text_field :username %>
  </div>
```

_jos_ käyttäjän tietoja ollaan editoimassa, eli käyttäjäolio on jo luotu aiemmin. 

Lomake voi kysyä oliolta <code>@user</code> onko se vielä tietokantaan tallentamaton metodin <code>new_record?</code> avulla. Näin saadaan <code>username</code>-kenttä näkyville lomakkeeseen ainoastaan sillon kuin kyseessä on uuden käyttäjän luominen:

```erb
  <% if @user.new_record? %>
    <div class="field">
      <%= f.label :username %><br />
      <%= f.text_field :username %>
    </div>
  <% end %>
```

Nyt lomake on kunnossa, mutta käyttäjänimeä on edelleen mahdollista muuttaa lähettämällä HTTP POST -pyyntö suoraan palvelimelle siten, että mukana on uusi username. 

Tehdään vielä User-kontrollerin <code>update</code>-metodiin tarkastus, joka estää käyttäjänimen muuttamisen:

```ruby
  def update
    respond_to do |format|
      if user_params[:username].nil? and @user == current_user and @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end
```

Muutosten jälkeen käyttäjän tietojen muuttamislomake näyttää seuraavalta:

![kuva](https://github.com/mluukkai/WebPalvelinohjelmointi2014/raw/master/images/ratebeer-w3-7.png)

> ## Tehtävä 14
>
> Ainoa käyttäjään liittyvä tieto on nyt salasana, joten muuta käyttäjän tietojen muuttamiseen tarkoitettua lomaketta siten, että se näyttää allaolevassa kuvassa olevalta. Huomaa, että uuden käyttäjän rekisteröitymisen (signup) on edelleen näytettävä samalta kuin ennen.

![kuva](https://github.com/mluukkai/WebPalvelinohjelmointi2014/raw/master/images/ratebeer-w3-8.png)



## Tehtävien palautus

Commitoi kaikki tekemäsi muutokset ja pushaa koodi Githubiin. Deployaa myös uusin versio Herokuun.

Tehtävät kirjataan palautetuksi osoitteeseen http://wadrorstats2014.herokuapp.com/courses/1

