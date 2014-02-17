Jatkamme sovelluksen rakentamista siitä, mihin jäimme viikon 5 lopussa. Allaoleva materiaali olettaa, että olet tehnyt kaikki edellisen viikon tehtävät. Jos et tehnyt kaikkia tehtäviä, voit ottaa kurssin repositorioista [edellisen viikon mallivastauksen](https://github.com/mluukkai/WebPalvelinohjelmointi2014/tree/master/malliv/viikko5). Jos sait suurimman osan edellisen viikon tehtävistä tehtyä, saattaa olla helpointa, että täydennät vastaustasi mallivastauksen avulla.

Jos otat edellisen viikon mallivastauksen tämän viikon pohjaksi, kopioi hakemisto muualle kurssirepositorion alta (olettaen että olet kloonannut sen) ja tee sovelluksen sisältämästä hakemistosta uusi repositorio. 

**Huom:** muutamilla Macin käyttäjillä oli ongelmia Herokun tarvitseman pg-gemin kanssa. Paikallisesti gemiä ei tarvita ja se määriteltiinkin asennettavaksi ainoastaan tuotantoympäristöön. Jos ongelmia ilmenee, voit asentaa gemit antamalla <code>bundle install</code>-komentoon seuraavan lisämääreen:

    bundle install --without production

Tämä asetus muistetaan jatkossa, joten pelkkä `bundle install` riittää kun haluat asentaa uusia riippuvuuksia.

## Viikon tehtävien luonteesta

Viikon materiaali- ja tehtävämäärä on suuri. Ei kuitenkaan hätää, viikon tehtävämaksimiksi lasketaan 12. Tekemällä enemmän tehtäviä voitkin paikata menneiden viikkojen tekemättä jääneitä tehtäviä.

Viikko sisältää muutaman toisistaan riippumattoman teeman:
* selainpuolella toteutettu toiminnallisuus, tehtävät 2-4
* bootstrap, tehtävät 5-7
* suorituskyvyn optimointi, tehtävät 14-17

Voit halutessasi jättää osan teemoista kokonaan välistä. 
Oikeastaan viikon ainoa tehtävien välinen riippuvuus on tehtäväkokonaisuuden 8-10 ja tehtävän 17 välillä. 

Koetta ajatellen selainpuolella toteutettu toiminnallisuus ja etenkin bootstrap ovat aihepiireinä tärkeydeltään sekundäärisiä. Suorituskykyyn liittyvät asiat kannattaa ehdottomasti vähintään lukea läpi.

**Tehtävien deadline poikkeuksellisesti vasta maanantaina 24.2. klo 23.59**

## Muistutus debuggerista

Viikolla 2 tutustuimme [byebug-debuggerin](https://github.com/mluukkai/WebPalvelinohjelmointi2014/blob/master/web/viikko2.md#debuggeri). Valitettavasti debuggeri ei ole vielä löytänyt tietänsä jokaisen kurssilaisen työkaluvalikoimaan.

Debuggerin käyttö on erittäin helppoa. Riittää kirjoittaa komento <code>byebug</code> _mihin tahansa_ kohtaan sovelluksen koodia. Seuraavassa esimerkki:

```ruby
class PlacesController < ApplicationController
   # ...

  def search
    byebug
    @places = BeermappingApi.places_in(params[:city])
    session[:previous_city] = params[:city]
    if @places.empty?
      redirect_to places_path, notice: "No locations in #{params[:city]}"
    else
      render :index
    end
  end
end
```

Tarkastelemme siis debuggerilla BeermappingApia käyttävää osaa sovelluksesta. Kun nyt sovelluksella haetaan jotain olutravintolaa avaa debuggeri konsolisession koodiin merkittyyn kohtaan:

```ruby
[6, 15] in /Users/mluukkai/kurssirepot/wadror/ratebeer/app/controllers/places_controller.rb
    6:     @place = BeermappingApi.find(params[:id],session[:previous_city] )
    7:   end
    8: 
    9:   def search
   10:     byebug
=> 11:     @places = BeermappingApi.places_in(params[:city])
   12:     session[:previous_city] = params[:city]
   13:     if @places.empty?
   14:       redirect_to places_path, notice: "No locations in #{params[:city]}"
   15:     else

(byebug) params
{"utf8"=>"✓", "authenticity_token"=>"KA26q0QTqbFhnyuql7k3W4iwGlgUky3wwz1PwypUy+4=", "city"=>"helsinki", "commit"=>"Search", "action"=>"search", "controller"=>"places"}
(byebug) params[:city]
"helsinki"
(byebug) 
```

eli pystymme mm. tarkastamaan että <code>params</code> hashin sisältö on sellainen kuin oletamme sen olevan.

Suoritetaan sitten seuraava komento ja katsotaan että tulos on odotetun kaltainen:

```ruby
(byebug) next

[7, 16] in /Users/mluukkai/kurssirepot/wadror/ratebeer/app/controllers/places_controller.rb
    7:   end
    8: 
    9:   def search
   10:     byebug
   11:     @places = BeermappingApi.places_in(params[:city])
=> 12:     session[:previous_city] = params[:city]
   13:     if @places.empty?
   14:       redirect_to places_path, notice: "No locations in #{params[:city]}"
   15:     else
   16:       render :index

(byebug) @places.size
7
(byebug) @places.first
#<Place:0x007fc9d7491878 @id="6742", @name="Pullman Bar", @status="Beer Bar", @reviewlink="http://beermapping.com/maps/reviews/reviews.php?locid=6742", @proxylink="http://beermapping.com/maps/proxymaps.php?locid=6742&d=5", @blogmap="http://beermapping.com/maps/blogproxy.php?locid=6742&d=1&type=norm", @street="Kaivokatu 1", @city="Helsinki", @state=nil, @zip="00100", @country="Finland", @phone="+358 9 0307 22", @overall="72.500025", @imagecount="0">
(byebug) @places.first.name
"Pullman Bar"
(byebug) continue
```

viimeinen komento jatkaa ohjelman normaalia suorittamista.

Debuggerin voi siis käynnistää _mistä tahansa kohtaa_ sovelluksen koodia, myös testeistä tai jopa näkymistä. Kokeillaan debuggerin käynnistämistä uuden oluen luomislomakkeen renderöinnin aikana:

```erb
[10, 19] in /Users/mluukkai/kurssirepot/wadror/ratebeer/app/views/beers/_form.html.erb
   10:       </ul>
   11:     </div>
   12:   <% end %>
   13: 
   14:   <% byebug %>
=> 15: 
   16:   <div class="field">
   17:     <%= f.label :name %><br>
   18:     <%= f.text_field :name %>
   19:   </div>

(byebug) @styles.size
5
(byebug) @styles.first
#<Style id: 1, name: "European pale lager", description: "Similar to the Munich Helles story, many European c...", created_at: "2014-02-05 17:44:15", updated_at: "2014-02-05 18:21:13">
(byebug) options_from_collection_for_select(@styles, :id, :name, selected: @beer.style_id)
"<option value=\"1\">European pale lager</option>\n<option value=\"2\">American pale ale</option>\n<option value=\"3\">Baltic porter</option>\n<option value=\"4\">Weizen</option>\n<option value=\"5\">Sahti</option>"
(byebug) 
```

Näkymätemplateen on siis lisätty <code><% byebug %></code>. Kuten huomaamme, on jopa näkymän apumetodin <code>options_from_collection_for_select</code> kutsuminen mahdollista debuggerista käsin!

Eli vielä kertauksena **kun kohtaat ongelman, turvaudu arvailun sijaan byebugiin!** 

Rails-konsolin käytön tärkeyttä sovelluskehityksen välineenä on yritetty korostaa läpi kurssin. Eli **kun teet jotain vähänkin epätriviaalia, testaa asia ensin konsolissa.** Joissain tilanteissa voi olla jopa parempi tehdä kokeilut debuggerin avulla avautuvassa konsolissa, sillä tällöin on mahdollista avata konsolisessio juuri siihen kontekstiin, mihin koodia ollaan kirjoittamassa. Näin ollen päästään käsiksi esim. muuttujiin <code>params</code>, <code>sessions</code> ym. suorituskontekstista riippuvaan dataan.

## Erilaiset järjestykset

Päätetään toteuttaa oluiden listalle toiminnallisuus, jonka avulla oluet voidaan järjestää eri sarakkeiden perusteella. Välitetään tieto halutusta järjestyksestä kontrollerille HTTP-pyynnön parametrina. Muutetaan näkymässä ```app/views/beers/index.html.erb``` olevaa taulukkoa seuraavasti:

```erb
<table>
  <thead>
    <tr>
      <th> <%= link_to 'Name', beers_path(order:"name") %> </th>
      <th> <%= link_to 'Style', beers_path(order:"style") %> </th>
      <th> <%= link_to 'Brewery', beers_path(order:"brewery") %> </th>
    </tr>
  </thead>

  <tbody>
    <% @beers.each do |beer| %>
      <tr>
        <td><%= link_to beer.name, beer %></td>
        <td><%= link_to beer.style, beer.style %></td>
        <td><%= link_to beer.brewery.name, beer.brewery %></td>
      </tr>
    <% end %>
  </tbody>
</table>
```

eli taulukon sarakkeiden otsikoista on nyt tehty linkit, jotka johtavat takaisin samalle sivulle mutta lisäävät pyyntöön parametrin <code>:order</code>, joka määrittelee halutun järjestyksen.

Kontrolleri pääsee HTTP-pyynnön parametriin käsiksi <code>params</code>-hashin avulla ja kuten olettaa saattaa, suunnan määrittelevän parametrin arvo on <code>params[:order]</code>.

Laajennetaan oluiden kontrolleria siten, että se testaa onko pyynnössä parametria, ja jos on, oluet järjestetään halutulla tavalla:

```ruby
  def index
    @beers = Beer.all

    order = params[:order] || 'name'

    case order
      when 'name' then @beers.sort_by!{ |b| b.name }
      when 'brewery' then @beers.sort_by!{ |b| b.brewery.name }
      when 'style' then @beers.sort_by!{ |b| b.style.name }
    end
  end
```

Koodi määrittelee järjestämisen tapahtuvan oletusarvoisesti nimen perusteella. Tämä tapahtuu seuraavasti

```ruby
    order = params[:order] || 'name'
```

Normaalisti <code>order</code> saa arvon <code>params[:order]</code>, jos parametria <code>:order</code> ei ole asetettu, eli sen arvo on <code>nil</code>, tulee arvoksi ||:n jälkeinen osa eli 'name'.

Huom: käytimme järjestämiseen metodia <code>sort_by!</code>, joka järjestää taulukon, jolle metodia kutsutaan. Metodista on myös olemassa huutomerkitön versio <code>sort_by</code> joka ei järjestä taulukkoa jolle metodia kutsutaan vaan luo siitä kopion, joka on halutussa järjestyksessä. 

Huom2: esimerkissä oluet haetaan ensin tietokannasta ja sen jälkeen järjestetään ne keskusmuistissa. Oluiden lista olisi mahdollista järjestää myös tietokantatasolla:

```ruby
   # oluet nimen perusteella järjestettynä
   Beer.order(:name)  


   # oluet panimoiden nimien perusteella järjestettynä   
   Beer.includes(:brewery).order("breweries.name")
```

> ## Tehtävä 1
>
> Muuta panimot listaavaa sivua siten, että panimot voidaan järjestää nimen mukaiseen aakkosjärjestykseen tai perustamisvuoden mukaiseen järjestykseen. Nimenmukainen järjestys on oletusarvoinen. 

## Selainpuolella toteutettu toiminnallisuus

Ratkaisumme oluiden listan järjestämiseen on melko hyvä. Suorituskyvyn kannalta hieman ongelmallista on tosin se, että aina järjestettäessä tehdään kutsu palvelimelle, joka generoi uudessa järjestyksessä näytettävän sivun.

Järjestämistoiminnallisuus voitaisiin toteuttaa myös selaimen puolella javascriptillä. Vaikka kurssi keskittyy palvelinpuolen toiminnallisuuteen, näytetään seuraavassa esimerkki siitä, miten järjestämistoiminnallisuus toteutettaisiin selainpuolella. Tässä ratkaisussa palvelin tarjoaa ainoastaan oluiden listan json-muodossa, ja selaimessa suoritettava javascript-koodi hoitaa myös oluet listaavan taulukon muodostamisen.

Emme korvaa nyt olemassaolevaa oluiden listaa, eli sivun beers toiminnallisuutta, sen sijaan tehdään toiminnallisuutta varten kokonaan uusi, osoitteessa beerlist toimiva sivu. Tehdään sivua varten reitti tiedostoon routes.rb:

    get 'beerlist', to:'beers#list'

Käytämme siis olutkontrollerissa olevaa <code>list</code>-metodia. Metodin ei tarvitse tehdä mitään:

```ruby
class BeersController < ApplicationController
  before_action :ensure_that_signed_in, except: [:index, :show, :list]
  # muut before_actionit enallaan

  def list
  end

  ...
end
```

Myös näkymä on views/beers/list.html.erb on minimalistinen:

```erb
<h2>Beers</h2>

<div id="beers"></div>
```

Eli näkymä ainoastaan sijoittaa sivulle div-elementin, jolle annetaan id:ksi (eli viitteksi jolla elementtiin päästään käsiksi) "beers".

Kuten odotettua, osoitteessa http://localhost:3000/beerlist ei nyt näy mitään muuta kuin h2-elementin sisältö.

Alamme nyt kirjoittamaan toimintalogiikan toteutusta javascriptillä hyödyntäen JQuery-kirjastoa. 

Jotta saamme JQueryn toimimaan hyvin yhteen Railsin ns. [turbolinks](https://github.com/rails/turbolinks)-ominaisuuden kanssa, otetaan käyttöön gemi https://github.com/kossnocorp/jquery.turbolinks eli lisätään Gemfileen rivi

    gem 'jquery-turbolinks'

tämän lisäksi tiedoston app/assets/javascripts/application.js on **lisättävä** rivien

    //= require jquery
    //= require jquery_ujs

väliin rivi

    //= require jquery.turbolinks


Rails-sovelluksen tarvitsema javascript-koodi kannattaa sijoittaa hakemistoon app/assets/javascripts. Tehdään hakemistoon tiedosto beerlist.js jolla on seuraava sisältö:

```javascript
$(document).ready(function () {
    $('#beers').html("hello from javascript");
    console.log("hello console!");
});
```

Kun sivu  nyt avataan uudelleen, asetetaan javascriptillä tai tarkemmin sanottuna jQuery-kirjastolla id:n <code>beers</code> omaavaan elementtiin teksti "hello form javascript". Seuraava komento kirjoittaa javascript-konsoliin tervehdyksen. 

Javascript-ohjelmoinnissa selaimessa oleva konsoli on **erittäin tärkeä** työväline. Konsolin saa avattua chromessa tools-valikosta tai painamalla ctrl, shift, j (linux) tai alt, cmd, i (mac). 

Javascript näyttää aluksi melko kryptiseltä, mm. paljon käytettyjen anonyymifunktioiden takia. Edellä oleva koodi määrittelee että <code>$(document).ready</code>-tapahtuman yhteydessä suoritetaan anonyymifunktion määrittelemä koodi: 

```javascript
(function () {
    $('#beers').html("hello from javascript");
    console.log("hello console!");
}
```

<code>$(document).ready</code> taas on tapahtuma (engl. event), joka tapahtuu koko www-sivun HTML-koodin ollessa latautunut selaimelle.


Jos kokeilemme selaimella osoitetta [http://localhost:3000/beers.json](http://localhost:3000/beers.json) huomaamme, että saamme vastaukseksi oluiden tiedot tekstuaalisessa json-muodossa (ks. http://en.wikipedia.org/wiki/JSON, http:www.json.org):

```ruby
[{"id":6,"name":"Hefeweizen","style":{"id":4,"name":"Weizen","description":"A south German style of wheat beer (weissbier) made with a typical ratio of 50:50, or even higher, wheat. A yeast that produces a unique phenolic flavors of banana and cloves with an often dry and tart edge, some spiciness, bubblegum or notes of apples. Little hop bitterness, and a moderate level of alcohol. The \"Hefe\" prefix means \"with yeast\", hence the beers unfiltered and cloudy appearance. Poured into a traditional Weizen glass, the Hefeweizen can be one sexy looking beer. \r\n\r\nOften served with a lemon wedge (popularized by Americans), to either cut the wheat or yeast edge, which many either find to be a flavorful snap ... or an insult and something that damages the beer's taste and head retention.","created_at":"2014-02-05T17:44:15.892Z","updated_at":"2014-02-05T18:25:02.337Z"},"brewery_id":3,"url":"http://localhost:3000/beers/6.json"},{"id":7,"name":"Helles","style":{"id":1,"name":"European pale lager","description":"Similar to the Munich Helles story, many European countries reacted to the popularity of early pale lagers by brewing their own. Hop flavor is significant and of noble varieties, bitterness is moderate, and both are backed by a solid malt body and sweetish notes from an all-malt base.","created_at":"2014-02-05T17:44:15.873Z","updated_at":"2014-02-05T18:21:13.441Z"},"brewery_id":3,"url":"http://localhost:3000/beers/7.json"},{"id":4,"name":"Huvila Pale Ale","style":{"id":2,"name":"American pale ale","description":"Of British origin, this style is now popular worldwide and the use of local ingredients, or imported, produces variances in character from region to region. Generally, expect a good balance of malt and hops. Fruity esters and diacetyl can vary from none to moderate, and bitterness can range from lightly floral to pungent. \r\n\r\nAmerican versions tend to be cleaner and hoppier, while British tend to be more malty, buttery, aromatic and balanced.","created_at":"2014-02-05T17:44:15.887Z","updated_at":"2014-02-05T18:22:25.674Z"},"brewery_id":2,"url":"http://localhost:3000/beers/4.json"},{"id":1,"name":"Iso 3","style":{"id":1,"name":"European pale lager","description":"Similar to the Munich Helles story, many European countries reacted to the popularity of early pale lagers by brewing their own. Hop flavor is significant and of noble varieties, bitterness is moderate, and both are backed by a solid malt body and sweetish notes from an all-malt base.","created_at":"2014-02-05T17:44:15.873Z","updated_at":"2014-02-05T18:21:13.441Z"},"brewery_id":1,"url":"http://localhost:3000/beers/1.json"},{"id":2,"name":"Karhu","style":{"id":1,"name":"European pale lager","description":"Similar to the Munich Helles story, many European countries reacted to the popularity of early pale lagers by brewing their own. Hop flavor is significant and of noble varieties, bitterness is moderate, and both are backed by a solid malt body and sweetish notes from an all-malt base.","created_at":"2014-02-05T17:44:15.873Z","updated_at":"2014-02-05T18:21:13.441Z"},"brewery_id":1,"url":"http://localhost:3000/beers/2.json"}]
```

Tarkemmin tarkasteltuna jokainen yksittäinen json-muotoinen olut muistuttaa hyvin paljon Rubyn hashiä:

```ruby
{"id":6,"name":"Hefeweizen","style":{"id":4,"name":"Weizen","description":"A south German style of wheat beer (weissbier) made with a typical ratio of 50:50, or even higher, wheat. A yeast that produces a unique phenolic flavors of banana and cloves with an often dry and tart edge, some spiciness, bubblegum or notes of apples. Little hop bitterness, and a moderate level of alcohol. The \"Hefe\" prefix means \"with yeast\", hence the beers unfiltered and cloudy appearance. Poured into a traditional Weizen glass, the Hefeweizen can be one sexy looking beer. \r\n\r\nOften served with a lemon wedge (popularized by Americans), to either cut the wheat or yeast edge, which many either find to be a flavorful snap ... or an insult and something that damages the beer's taste and head retention.","created_at":"2014-02-05T17:44:15.892Z","updated_at":"2014-02-05T18:25:02.337Z"},"brewery_id":3,"url":"http://localhost:3000/beers/6.json"}
```

Minkä takia Rails osaa tarvittaessa palauttaa resurssit HTML:n sijaan jsonina? 

Yritetään saada kaikkien reittausten lista jsonina, eli kokeillaan osoitetta [http://localhost:3000/ratings.json](http://localhost:3000/ratings.json)

Seurauksena on virheilmoitus:

![kuva](https://github.com/mluukkai/WebPalvelinohjelmointi2014/raw/master/images/ratebeer-w6-1.png)

Eli ihan automaattisesti jsonit eivät synny, loimme kaiken reittaukseen liittyvän koodin käsin, ja kuten virheilmoituksesta voimme päätellä, formaatille 'json' ei ole olemassa sopivaa templatea.

Huomaamme, että scaffoldilla luotujen resurssien, esim oluen views-hakemistosta löytyy joukko _json.jbuilder-päätteisiä templateja, ja kuten arvata saattaa, käyttää Rails näitä jos resurssi halutaan json-muotoisena.

Ottamalla mallia templatesta app/views/beers/index.json.jbuilder teemme reittauksille seuraavan json.jbuilder-templaten (tiedosto on siis app/views/ratins/index.json.jbuilder):

```ruby
json.array!(@ratings) do |rating|
  json.extract! rating, :id, :score
end
```

ja nyt saamme reittaukset jsonina osoitteesta [http://localhost:3000/ratings.json](http://localhost:3000/ratings.json)

```ruby
[{"id":1,"score":13},{"id":2,"score":34},{"id":3,"score":25}]
```

Voisimme helposti määritellä json.jbuilder-templatessa, että reittausten json-esitykseen sisällytetään myös reittausta koskevan oluen tiedot:

```ruby
json.array!(@ratings) do |rating|
  json.extract! rating, :id, :score, :beer
end
```

Lisää jbuilderista seuraavissa http://railscasts.com/episodes/320-jbuilder?autoplay=true ja https://github.com/rails/jbuilder

Json-jbuilder-templatejen ohella toinen tapa palauttaa json-muotoista dataa olisi käytää <code>respond_to</code>-komentoa jota muutamat scaffoldienkin generoivat metodit käyttävät. Tällöin json-jbuilder-templatea ei tarvittaisi ja kontrolleri näyttäisi seuraavalta

```ruby
  def index
    @ratings = Rating.all

    respond_to do |format|
      format.html { } # renderöidään oletusarvoinen template 
      format.json { render json: @ratings }
    end
  end
```

Jbuilder-templatejen käyttö on kuitenkin ehdottomasti parempi vaihtoehto, tällöin json-muotoisen "näytön" eli resurssin representaation muodostaminen eriytetään täysin kontrollerista. Ei ole kontrollerin vastuulla muotoilla vastauksen ulkoasua oli kyseessä sitten json- tai HTML-muotoinen vastaus.

Palataan oluiden sivun pariin. Kun muodostamme sivun javascriptillä, ideana onkin hakea palvelimelta nimenomaan oluet json-muodossa ja renderöidä ne sitten sopivasti javascriptin avulla. 

Muokataan javascript-koodiamme seuraavasti:
 
```javascript
$(document).ready(function () {
    $.getJSON('beers.json', function (beers) {
        oluet = beers
        $("#beers").html("oluita löytyi "+beers.length);
    });
});
```

Koodin ensimmäinen rivi (joka siis suoritetaan heti kun sivu on latautunut) tekee HTTP GET -kyselyn palvelimen osoitteeseen beers.json ja määrittelee takaisinkutsufunktion, jota selain kutsuu siinä vaiheessa kun GET-kyselyyn tulee vastaus palvelimelta. Takaisinkutsufunktion parametrissa <code>beers</code> on palvelimelta tullut data, eli json-muodossa oleva oluiden lista. Muuttujan sisältö sijoitetaan globaaliin muuttujaan <code>oluet</code> ja oluiden listan pituus näytetään www-sivulla id:n beers omaavassa elementissä. 

Koska sijoitimme viitteen oluiden listan globaaliin muuttujaan, voimme tarkastella sitä selaimen konsolista käsin (muistutuksena että konsolin saa avattua chromessa tools-valikosta tai painamalla alt, shift ja i):

```ruby
> oluet
[ Object, Object, Object, Object, Object, Object, Object, Object]
> oluet[0]
Object {id: 6, name: "Hefeweizen", style: Object, brewery_id: 3, url: "http://localhost:3000/beers/6.json"…}
> oluet[0]['name']
"Hefeweizen"
```

JSON-muodossa javascipt-oliota voi tarkastella konsolissa komennolla JSON.stringify(olio):

```ruby
> JSON.stringify(oluet[0])
"{"id":6,"name":"Hefeweizen","style":{"id":4,"name":"Weizen","description":"A south German style of wheat beer (weissbier) made with a typical ratio of 50:50, or even higher, wheat. A yeast that produces a unique phenolic flavors of banana and cloves with an often dry and tart edge, some spiciness, bubblegum or notes of apples. Little hop bitterness, and a moderate level of alcohol. The \"Hefe\" prefix means \"with yeast\", hence the beers unfiltered and cloudy appearance. Poured into a traditional Weizen glass, the Hefeweizen can be one sexy looking beer. \r\n\r\nOften served with a lemon wedge (popularized by Americans), to either cut the wheat or yeast edge, which many either find to be a flavorful snap ... or an insult and something that damages the beer's taste and head retention.","created_at":"2014-02-05T17:44:15.892Z","updated_at":"2014-02-05T18:25:02.337Z"},"brewery_id":3,"url":"http://localhost:3000/beers/6.json"}"
```

Takaisinkutsufunktion pitäisi siis saatuaan oluet palvelimelta muodostaa ne listaava HTML-koodi ja lisätä se sivulle. 

Muutetaan javascript-koodiamme siten, että se listaa aluksi ainoastaan oluiden nimet:

```javascript
    $.getJSON('beers.json', function (beers) {
        var beer_list = [];

        $.each(beers, function (index, beer) {
            beer_list.push('<li>' + beer['name'] + '</li>')
        });

        $("#beers").html('<ul>'+ beer_list.join('') + '</ul>');
     });
```

Koodi määrittelee paikallisen taulukkomuuttujan <code>beer_list</code> ja käy läpi parametrina saamansa oluiden listan <code>beers</code> (hieman erikoiselta näyttävää jqueryn <code>each</code>-metodia käyttäen, ks. http://api.jquery.com/jQuery.each/), ja lisää jokaista olutta kohti <code>beer_list</code>:iin HTML-elementin, joka on muotoa

```erb
    <li>Karhu tuplahumala</li>
```

Lopuksi listan alkuun ja loppuun lisätään ul-tagit ja listan alkiot liitetään yhteen join-metodilla. Näin saatu HTML-koodi liitetään id:n <code>beers</code> omaavaan elementtiin.

Nyt siis saimme yksinkertaisen listan oluiden nimistä sivulle. 

Entä jos haluaisimme järjestää oluet? Jotta tämä onnistuu, refaktoroimme koodin ensin seuraavanlaiseksi:

```javascript
var BEERS = {};

BEERS.show = function(){
    var beer_list = [];

    $.each(BEERS.list, function (index, beer) {
        beer_list.push('<li>' + beer['name'] + '</li>')
    });

    $("#beers").html('<ul>'+ beer_list.join('') + '</ul>');
};

$(document).ready(function () {

    $.getJSON('beers.json', function (beers) {
        BEERS.list = beers;
        BEERS.show();
     });
});
```

Määrittelimme nyt olion <code>BEERS</code>, jonka attribuuttiin <code>BEERS.list</code> palvelimelta saapuva oluiden lista sijoitetaan. Metodi <code>BEERS.show</code> muodostaa <code>BEERS.list</code>:in oluista HTML-taulukon ja sijoittaa sen näytölle.

Näin muotoiltuna palvelimelta haettu oluiden lista jää "muistiin" selaimeen muuttujaan <code>BEERS.list</code> ja lista voidaan tarpeen tullen uudelleenjärjestää ja näyttää käyttäjälle uudessa järjestyksessä ilman että www-sivun tarvitsee ollenkaan kommunikoida palvelimen kanssa.

Lisätään sivulle painike (tai linkki), jota painamalla oluet saadaan sivulle käänteiseen järjestykseen:

```erb
<a href="#" id="reverse">reverse!</a>
<div id="beers"></div>
```

Lisätään sitten javascriptillä linkille klikkauksenkäsittelijä, joka linkkiä klikatessa laittaa oluet käänteiseen järjestykseen ja näyttää ne  sivun beers-elementissä:

```javascript
var BEERS = {};

BEERS.show = function(){
    var beer_list = [];

    $.each(BEERS.list, function (index, beer) {
        beer_list.push('<li>' + beer['name'] + '</li>')
    });

    $("#beers").html('<ul>'+ beer_list.join('') + '</ul>');
};

BEERS.reverse = function(){
    BEERS.list.reverse();
};

$(document).ready(function () {
    $("#reverse").click(function (e) {
        BEERS.reverse();
        BEERS.show();
        e.preventDefault();
    });

    $.getJSON('beers.json', function (beers) {
        BEERS.list = beers;
        BEERS.show();
    });
});
```

Linkin klikkauksen käsittelijä siis määritellään tapahtuman <code>document ready</code> sisällä, eli kun dokumentti on latautunut, rekisteröidään klikkausten käsittelijäfunktio id:n "reverse" omaavalle linkkielementille. Selain kutsuu määriteltyä funktiota kun linkkiä klikataan. Viimeiseksi komento <code>preventDefault</code> estää klikkauksen "normaalin" toiminnallisuuden eli (nyt olemattoman) linkin seuraamisen. 

Nyt ymmärrämme riittävästi perusteita ja olemme valmiina toteuttamaan todellisen toiminnallisuuden.

Muutetaan näkymää seuraavasti:

```erb
<h2>Beers</h2>

<table id="beertable">
  <tr>
    <th> <a href="#" id="name">Name</a> </th>
    <th> <a href="#" id="style">Style</a> </th>
    <th> <a href="#" id="brewery">Brewery</a> </th>
  </tr>

</table>
```

Eli kolmesta sarakenimestä on tehty linkki, joihin tullaan rekisteröimään klikkauksenkuuntelijat. Taulukolle on annettu id <code>beertable</code>.

Muutetaan sitten javascriptissä määriteltyä metodia <code>show</code> siten, että se laittaa oluiden nimet taulukkoon:

```javascript
BEERS.show = function(){
    var table = $("#beertable");

    $.each(BEERS.list, function (index, beer) {
        table.append('<tr><td>'+beer['name']+'</td></tr>');
    });
};
```

Eli ensin koodi tallettaa viitteen taulukkoon muuttujana <code>table</code> ja lisää sinne <code>append</code>-komennolla uuden rivin kutakin olutta varten.

Laajennetaan sitten metodia näyttämään kaikki tiedot oluista. Huomaamme kuitenkin, että oluiden json-muotoisessa listassa ei ole panimosta muuta tietoa kuin olioiden id:t, haluaisimme kuitenkin näyttää panimon nimen. Oluttyylin tiedot löytyvät kokonaisuudessaan jsonista jo nyt.

Ongelma on onneksi helppo ratkaista muokkaamalla oluiden listan tuottavaa json-jbuildertemplatea. Template näyttää nyt seuraavalta:

```ruby
json.array!(@beers) do |beer|
  json.extract! beer, :id, :name, :style, :brewery_id
  json.url beer_url(beer, format: :json)
end
```

Template määrittelee, että jokaisesta oluesta json-esitykseen sisällytetään kentät _id_, _name_ ja _brewery_id_ sekä _style_ joka taas viittaa olueeseen liittyvään <code>Style</code>-olioon. Tyyliolio tuleekin renderöityä oluen json-esityksen sisälle kokonaisuudessaan. Saamme myös panimon json-esityksen oluen jsonin mukaan jos korvaamme templatessa _brewery_id_:n _brewery_:llä. Muutamme siis templaten muotoon:

```ruby
json.array!(@beers) do |beer|
  json.extract! beer, :id, :name, :style, :brewery
end
```

poistimme viimeisen rivin joka lisäsi jokaisen oluen json-esityksen mukaan urlin oluen omaan json-esitykseen.

Nyt saamme taulukon generoitua seuraavalla javascriptillä:

```javascript
BEERS.show = function(){
    var table = $("#beertable");

    $.each(BEERS.list, function (index, beer) {
        table.append('<tr>'
                        +'<td>'+beer['name']+'</td>'
                        +'<td>'+beer['style']['name']+'</td>'
                        +'<td>'+beer['brewery']['name']+'</td>'
                    +'</tr>');
    });
};
```

Oluiden listan json-esityksen mukana tulee nyt paljon tarpeetontakin tietoa sillä mukaan renderöityvät jokaisen oluen panimon ja tyylin json-esitykset kokonaisuudessaan. Voisimme optimoida templatea siten, että oluen panimosta ja tyylistä tulee json-esitykseen mukaan ainoastaan nimi:

```ruby
json.array!(@beers) do |beer|
  json.extract! beer, :id, :name
  json.style do
    json.name beer.style.name
  end
  json.brewery do
    json.name beer.brewery.name
  end
end
```

Nyt palvelimen lähettämä oluiden jsonmuotoinen lista on huomattavasti inhimillisemmän kokoinen:

```ruby
[{"id":6,"name":"Hefeweizen","style":{"name":"Weizen"},"brewery":{"name":"Weihenstephaner"}},{"id":7,"name":"Helles","style":{"name":"European pale lager"},"brewery":{"name":"Weihenstephaner"}},{"id":4,"name":"Huvila Pale Ale","style":{"name":"American pale ale"},"brewery":{"name":"Malmgard"}},{"id":1,"name":"Iso 3","style":{"name":"European pale lager"},"brewery":{"name":"Koff"}},{"id":2,"name":"Karhu","style":{"name":"European pale lager"},"brewery":{"name":"Koff"}},{"id":8,"name":"Sierra Nevada Pale Ale","style":{"name":"American pale ale"},"brewery":{"name":"Sierra Nevada  Brewing"}},{"id":3,"name":"Tuplahumala","style":{"name":"European pale lager"},"brewery":{"name":"Koff"}},{"id":5,"name":"X Porter","style":{"name":"Baltic porter"},"brewery":{"name":"Malmgard"}}]
```

Yksittäisen oluen json-esitys vielä seuraavassa hieman luettavampaan muotoon sisennettynä:

```ruby
{
   "id":6,
   "name":"Hefeweizen",
   "style":{
       "name":"Weizen"
   },
   "brewery":{
       "name":"Weihenstephaner"
   }
}
```

Rekisteröimme vielä järjestämisen suorittavat tapahtumankuuntelijat linkeille (seuraavassa lopullinen javascript-koodi):

```javascript
var BEERS = {};

BEERS.show = function(){
    $("#beertable tr:gt(0)").remove();

    var table = $("#beertable");

    $.each(BEERS.list, function (index, beer) {
        table.append('<tr>'
            +'<td>'+beer['name']+'</td>'
            +'<td>'+beer['style']['name']+'</td>'
            +'<td>'+beer['brewery']['name']+'</td>'
            +'</tr>');
    });
};

BEERS.sort_by_name = function(){
    BEERS.list.sort( function(a,b){
        return a.name.toUpperCase().localeCompare(b.name.toUpperCase());
    });
};

BEERS.sort_by_style = function(){
    BEERS.list.sort( function(a,b){
        return a.style.name.toUpperCase().localeCompare(b.style.name.toUpperCase());
    });
};

BEERS.sort_by_brewery = function(){
    BEERS.list.sort( function(a,b){
        return a.brewery.name.toUpperCase().localeCompare(b.brewery.name.toUpperCase());
    });
};

$(document).ready(function () {
    $("#name").click(function (e) {
        BEERS.sort_by_name();
        BEERS.show();
        e.preventDefault();
    });

    $("#style").click(function (e) {
        BEERS.sort_by_style();
        BEERS.show();
        e.preventDefault();
    });

    $("#brewery").click(function (e) {
        BEERS.sort_by_brewery();
        BEERS.show();
        e.preventDefault();
    });

    $.getJSON('beers.json', function (beers) {
        BEERS.list = beers;
        BEERS.sort_by_name();
        BEERS.show();
    });

});

```

Javascript-koodimme tulee liitetyksi sovelluksen jokaiselle sivulle. Tästä on se ikävä seuraus, että ollaanpa millä sivulla tahansa, lataa javascript oluiden listan komennon <code>getJSON('beers.json', ...) </code> takia. Viritellään javascript-koodia vielä siten, että oluiden lista käydään lataamassa ainoastaan jos ollaan sivulla josta taulukko <code>beertable</code> löytyy:

```javascript
    if ( $("#beertable").length>0 ) {
      $.getJSON('beers.json', function (beers) {
        BEERS.list = beers;
        BEERS.sort_by_name;
        BEERS.show();
      });
    }
```

Tällä hetkellä trendinä siirtää yhä suurempi osa web-sivujen toiminnallisuudesta selaimeen. Etuna mm. se että web-sovelluksien toiminta saadaan muistuttamaan yhä enenevissä määrin desktop-sovelluksia.

## AngularJS

Äsken javascriptillä toteuttamamme oluet listaava sivu oli koodin rakenteen puolesta ihan kohtuullista mutta Railsin sujuvuuteen ja vaivattomuuteen verrattuna koodi oli raskaahkoa ja paikoin ikävien, rutiininomaisten yksityiskohtien täyttämää.

Katsotaan seuraavassa, miten sama toiminnallisuus toteutettaisiin viime aikoina suurta suosiota saaneen selainpuolen MVC (tai MVW, model view whatever… niinkuin Angularin kehittäjä on itse todennut) -sovelluskehyksen http://angularjs.org/  avulla. Angularissa on Railsin tavoin sopivasti sujuvuutta ja magiaa, ja monet Rails-yhteisön jäsenet ovatkin siirtyneet enenevissä määrin kirjoittamaan sovellusten selainpuolen toiminnallisuuden Angularilla.

Tehdään toiminnallisuutta varten uusi reitti tiedostoon routes.rb:

    get 'ngbeerlist', to:'beers#nglist'

ja tyhjä kontrollerimetodi:

```ruby
class BeersController < ApplicationController
  # muut before_actionit säilyvät ennallaan
  before_action :ensure_that_signed_in, except: [:index, :show, :list, :nglist]

  def nglist
  end
```

Tehdään tällä kertaa javascript-koodi näkymätemplaten sisään sijoitettavaan script-tagiin. Koodin voi halutessaan siirtää omaan tiedostoonsa. 

Näkymän app/views/beers/nglist.html.erb ensimmäinen versio on seuraavassa:

```javascript
<script src="//ajax.googleapis.com/ajax/libs/angularjs/1.2.10/angular.min.js"></script>
<script>
    function BeersController($scope, $http) {
        $scope.teksti = "Hello Angular!"
    }
</script>

<h2>Beers</h2>

<div ng-app ng-controller="BeersController">

  {{teksti}}

</div>
```

Sivulla olevan div-tagin sisällä määritellään että kyseessä on _ng-app_ eli Angular-sovellus. Div-tagin sisällä oleva koodi määritellään <code>BeersController</code>-nimisen kontrollerimetodin hallinnoivaksi. Huomaamme, että kontrollerimetodi asettaa muuttujan <code>$scope</code> kentän <code>teksti</code> arvoksi merkkijonon "Hello Angular!". Kaikki <code>$scope</code>-muttujan kentät ovat käytettävissä kontrollerin hallinnoimassa scopessa, siis myös näkymässä. Näkymä sisältää nyt erikoiselta näyttävän merkinnän <code>{{teksti}}</code>. Kun selain renderöi sivun käyttäjälle, tupla-aaltosulkujen sisällä oleva Angular-koodi suoritetaan ja sen tulos renderöityy ruudulle. Ruudulle siis renderöityy kontrollerin muuttujaan sijoittama merkkijono.

Muutetaan koodia seuraavasti:

```javascript
<script src="//ajax.googleapis.com/ajax/libs/angularjs/1.2.10/angular.min.js"></script>
<script>
    function BeersController($scope, $http) {
        $scope.beers = [{"id":6,"name":"Hefeweizen","style":{"name":"Weizen"},"brewery":{"name":"Weihenstephaner"}},{"id":7,"name":"Helles","style":{"name":"European pale lager"},"brewery":{"name":"Weihenstephaner"}},{"id":4,"name":"Huvila Pale Ale","style":{"name":"American pale ale"},"brewery":{"name":"Malmgard"}}];
    }
</script>

<h2>Beers</h2>

<div ng-app ng-controller="BeersController">

  <ul>
    <li ng-repeat="beer in beers">
      {{beer.name}} brewed by {{beer.brewery.name}}
    </li>
  </ul>

</div>
```

Nyt selaimeen renderöityy lista oluita panimoineen. Koodin ydin on seuraava

```javascript
<li ng-repeat="beer in beers">
   {{beer.name}} brewed by {{beer.brewery.name}}
</li>
```

Angularin _ng-repeat_ komento (tai direktiivi) luo jokaiselle scopessa olevan taulukon <code>beers</code> alkiolle oman li-tagin. Taulukon alkioihin viitataan tagin sisällä nimellä <code>beer</code>. Kuten huomaamme, ero Railsin näkymätemplateihin ei ole suuri. Huomattava ero tietenkin on se, että kaikki tapahtuu nyt selaimessa.

Angularin avulla on hyvin helppo hakea json-muotoinen data palvelimelta. Riittää, että muutetaan kontrollerifunktiota seuraavasti:

```javascript
    function BeersController($scope, $http) {
        $http.get('beers.json').success( function(data, status, headers, config) {
            $scope.beers = data;
        });
    }
```

<code>$http.get</code> tekee niinkuin olettaa saattaa GET-kutsun parametrina olevaan osoitteeseen. Rekisteröity takaisinkutsufunktio asettaa palvelimelta tulevan datan scopen muuttujaan <code>beers</code>.

Muutetaan sitten näkymätemplatea siten, että listan sijaan oluet näytetään taulukossa:

```html
<div ng-app ng-controller="BeersController">

  <table>
    <thead>
    <th> <a>name</a> </th>
    <th> <a>style</a> </th>
    <th> <a>brewery</a> </th>
    </thead>
    <tr ng-repeat="beer in beers">
      <td>{{beer.name}}</td>
      <td>{{beer.style.name}}</td>
      <td>{{beer.brewery.name}}</td>
    </tr>
  </table>

</div>
```

Lisäsimme myös järjestämistä varten otsikot jotka ovat a-tagin sisällä, eli linkkejä. Lisätään sitten järjestämistä varten tarvittava magia:

```javascript
<script src="//ajax.googleapis.com/ajax/libs/angularjs/1.2.10/angular.min.js"></script>
<script>
    function BeersController($scope, $http) {
        $http.get('beers.json').success( function(data, status, headers, config) {
            $scope.beers = data;
        });

        $scope.order = 'name';

        $scope.click = function (order){
            $scope.order = order;
            console.log(order);
        }
    }
</script>

<h2>Beers</h2>

<div ng-app ng-controller="BeersController">

  <table>
    <thead>
    <th> <a ng-click="click('name')">name</a> </th>
    <th> <a ng-click="click('style.name')">style</a> </th>
    <th> <a ng-click="click('brewery.name')">brewery</a> </th>
    </thead>
    <tr ng-repeat="beer in beers| orderBy:order">
      <td>{{beer.name}}</td>
      <td>{{beer.style.name}}</td>
      <td>{{beer.brewery.name}}</td>
    </tr>
  </table>

</div>
```

Lisäsimme koodiin muutaman asian. Määrittelimme scopeen metodin <code>click</code> (todella huono metodin nimi), jota klikkaamalla voidaan määritellä scopeen lisätyn muuttujan <code>order</code> arvo. Oletusarvoisesti arvona on 'name', mutta klikkaamalla panimosarakkeen otsikkoa, muuttuu arvoksi 'brewery.name' ja vastaavasti klikkaamalla tyylisarakkeen otsikkoa arvoksi muuttuu 'brewery.style'. ng-repeatiin on tehty seuraava lisäys:

```javascript
ng-repeat="beer in beers| orderBy:order"
```

nyt muuttujassa oleva kokoelma <code>beers</code> järjestetään <code>orderBy</code>-filtterin avulla muuttujan <code>order</code> arvon nimisen kentän perusteella.

Tehdään vielä bonuksena sovellukseen ominaisuus, jonka avulla näytettävien oluiden listan voi rajata:

```javascript
<script src="//ajax.googleapis.com/ajax/libs/angularjs/1.2.10/angular.min.js"></script>
<script>
    function BeersController($scope, $http) {
        $http.get('beers.json').success( function(data, status, headers, config) {
            $scope.beers = data;
        });

        $scope.order = 'name';

        $scope.click = function (order){
            $scope.order = order;
            console.log(order);
        }

        $scope.searchText = '';
    }
</script>

<h2>Beers</h2>

<div ng-app ng-controller="BeersController">
  search:  <input ng-model="searchText">

  <table>
    <thead>
    <th> <a ng-click="click('name')">name</a> </th>
    <th> <a ng-click="click('style.name')">style</a> </th>
    <th> <a ng-click="click('brewery.name')">brewery</a> </th>
    </thead>
    <tr ng-repeat="beer in beers| orderBy:order | filter:searchText">
      <td>{{beer.name}}</td>
      <td>{{beer.style.name}}</td>
      <td>{{beer.brewery.name}}</td>
    </tr>
  </table>

</div>
```

ng-repeatiin on lisätty vielä yksi filtteri, nimeltään <code>filter</code> joka rajaa kokoelmasta näytettävät olit niihin joissa esiintyy filtterin parametrina olevassa scopen muuttujassa <code>searchText</code> oleva merkkijono.

Etsintää rajoittava merkkijono syötetään input-tagin avulla:

```javascript
<input ng-model="searchText">
```

Kuten huomaat, Angularin magia päivittää scopessa olevan muuttujan <code>searchText</code> arvoa samalla kuin kirjoitat tekstiä hakukenttään.

Jos kiinnostus heräsi, jatka tutustumista esim. seuraavasta:
http://docs.angularjs.org/tutorial

Tällä hetkellä näyttää siltä että Angular valtaa alaa todella ripeää tahtia. Angularin oppimiskäyrä on "jääkiekkomailamainen", alkuun pääsee aika helposti, mutta kehys on laaja ja sen täysimittainen hallinta vaatii pitkäjänteistä perehtymistä. Onneksi Angularin käyttö ei ole kaikki tai ei mitään -ratkaisu. Mikään ei estä Angularin varovaista käyttöönottoa, esim. rikastamalla sivujen joitain osia Angularilla ja tuottamalla osa sisällöstä Railsin templatejen avulla palvelinpuolella. Näin on toimittu esim. kurssin laskaristatistiikkasivulla http://wadrorstats2014.herokuapp.com/, missä graafien piirtäminen hoidetaan Angularin ja GoogleChartsin avulla.

Ei ole vakiintunutta parasta käytännettä miten Rails+AngularJS-projetki kannattaisi organisoida. Eräs hyvä näkemys asiasta on seuraavassa
http://rockyj.in/2013/10/24/angular_rails.html

> ## Tehtävä 2
>
> Toteuta edellisten esimerkkien tyyliin javascriptillä (JQueryllä tai AngularJS:llä) kaikki panimot listaava http:localhost:3000/brewerylist sivu jolla panimot voi järjestää joko aakkos- tai perustamisvuoden mukaiseen järjestykseen tai panimon valmistamien oluiden lukumäärän perusteella.

## Selainpuolella toteutetun toiminnallisuuden testaaminen

Tehdään  rspec/capybaralla muutama testi javascriptillä toteutetulle oluiden listalle. Seuraavassa on lähtökohtamme, tiedosto spec/features/beerlist_spec.rb:

```ruby
require 'spec_helper'

describe "Beerlist page" do
  before :each do
    @brewery1 = FactoryGirl.create(:brewery, name:"Koff")
    @brewery2 = FactoryGirl.create(:brewery, name:"Schlenkerla")
    @brewery3 = FactoryGirl.create(:brewery, name:"Ayinger")
    @style1 = Style.create name:"Lager"
    @style2 = Style.create name:"Rauchbier"
    @style3 = Style.create name:"Weizen"
    @beer1 = FactoryGirl.create(:beer, name:"Nikolai", brewery: @brewery1, style:@style1)
    @beer2 = FactoryGirl.create(:beer, name:"Fastenbier", brewery:@brewery2, style:@style2)
    @beer3 = FactoryGirl.create(:beer, name:"Lechte Weisse", brewery:@brewery3, style:@style3)
  end

  it "shows one known beer" do
    visit beerlist_path
    expect(page).to have_content "Nikolai"
  end
end
```

Suoritetaan testi komennolla <code>rspec spec/features/beerlist_spec.rb</code>. Tuloksena on kuitenkin virheilmoitus (muista suorittaa <code>rake db:test:prepare</code> jos tietokantaskeema on muuttunut edellisen testien suorituksen jälkeen!):

```ruby
  1) beerlist page Beerlist page shows one known beer
     Failure/Error: expect(page).to have_content "Nikolai"
       expected to find text "Nikolai" in "breweries beers styles ratings users clubs places | signin signup Beers Name Style Brewery"
```

Näyttää siis siltä että sivulla ei ole ollenkaan oluiden listaa. Varmistetaan tämä laittamalla testiin juuri ennen komentoa <code>expect</code> komento <code>save_and_open_page</code> jonka avulla saamme siis avattua selaimeen sivun jolle capybara on navigoinut
(ks. https://github.com/mluukkai/WebPalvelinohjelmointi2014/blob/master/web/viikko4.md#capybarav4#capybara).

Ja aivan kuten arvelimme, sivulla näytettävä oluttaulukko on tyhjä:

![kuva](https://github.com/mluukkai/WebPalvelinohjelmointi2014/raw/master/images/ratebeer-w6-2.png)

Syy ongelmalle löytyy capybaran dokumentaatiosta https://github.com/jnicklas/capybara#drivers

> By default, Capybara uses the :rack_test driver, which is fast but limited: it does not support JavaScript, nor is it able to access HTTP resources outside of your Rack application, such as remote APIs and OAuth services. To get around these limitations, you can set up a different default driver for your features.

Ja korjauskin on helppo. Javascriptiä tarvitseviin testeihin riittää lisätä parametri, jonka ansiosta testi suoritetaan javascriptiä osaavan Selenium-testiajurin avulla:

```ruby
    it "shows the known beers", js:true do
```

Jotta selenium saadaan käyttöön, on Gemfilen test-scopeen lisättävä seuraava gem:

    gem 'selenium-webdriver' 

Suoritetaan <code>bundle install</code>, ja ajetaan testit. Jälleen törmäämme virheilmoitukseen:

```ruby
     Failure/Error: visit beerlist_path
     WebMock::NetConnectNotAllowedError:
       Real HTTP connections are disabled. Unregistered request: GET http://127.0.0.1:60873/__identify__ with headers {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}
```

Virheen syy on siinä, että otimme viikolla 5 käyttöömme WebMock-gemin joka oletusarvoisesti kieltää testikoodin suorittamat HTTP-yhteydet. Javascriptilla toteutettu olutlistahan yrittää hakea oluiden listan json-muodossa palvelimelta. Pääsemme virheestä eroon sallimalla yhteydet paikalliselle palvelimelle, eli lisäämällä esim.  <code>before</code>-lohkon alkuun seuraavan komennon:

    WebMock.disable_net_connect!(allow_localhost:true)

Testi toimii vihdoin, mutta ei mene läpi. Huomaamme että korjausta alkuperäiseen ongelmaan ei tapahdu: vaikka <code>before :each</code> -lohkossa lisäämme oluita tietokantaan, vaikuttaa tietokanta tyhjältä. 

Syynä tälle on se, että ajettaessa testejä Seleniumin kautta, rspecin normaali tapa suorittaa testi yhtenä tietokantatransaktiona (joka automaattisesti suorittaa rollback-operaation testin lopussa nollaten näin tietokantaan tapahtuneet muutokset) ei ole tuettu (ks. https://github.com/jnicklas/capybara#transactions-and-database-setup). Joudummekin kytkemään ominaisuuden pois päältä Seleniumin kautta ajettavien testien aluksi komennolla <code>self.use_transactional_fixtures = false</code>

Ikävä seuraus tästä on se, että testien tietokantaan tallettama data ei nyt automaattisesti poistu jokaisen testin jälkeen. DatabaseCleaner gemi https://github.com/bmabey/database_cleaner tuo kuitenkin avun tähän. Otetaan gem käyttöön määrittelemällä Gemfilen test-scopeen seuraava

    gem 'database_cleaner', '< 1.1.0'

Huom: joudumme käyttämään gemistä hieman vanhempaa versiota koska uusin versio ei ainakaan 14.4.2014 toiminut Railsin oletusarvoisen SQLite-tietokannan kanssa. Suoritetaan sitten tuttu <code>bundle install</code>.

Konfiguroidaan testit siten, että _ennen kaikkia testejä_ (<code>before :all</code>) laitetaan transaktionaalisuus pois päältä, sallitaan HTTP-yhteydet paikalliselle palvelimelle ja määritellään DatabaseCleanerille käytettävä strategia (ks. http://stackoverflow.com/questions/10904996/difference-between-truncation-transaction-and-deletion-database-strategies). _Jokaisen testin alussa_ (<code>before :each</code>) käynnistetään DatabaseCleaner ja jokaisen testin lopussa (<code>after :each</code>) pyydetään DatabseCleaneria tyhjentämään tietokanta. Kun kaikki testit on suoritettu (<code>after :all</code>) palautetaan normaali transaktionaalisuus:

```ruby
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
    save_and_open_page
    expect(page).to have_content "Nikolai"
  end
end
```

Jouduimme jo näkemään hieman vaivaa, mutta testi toimii vihdoin!

Kun sivuille luodaan sisältöä javascriptillä, ei sisältö ilmesty sivulle vielä samalla hetkellä kuin sivun html-pohja ladataan vaan vasta javascript takaisinkutsufunktion suorituksen jälkeen. Eli jos katsomme sivun sisältöä välittömästi sivulle navigoinnin jälkeen, ei javascript ole vielä ehtinyt muodostaa sivun lopullista sisältöä. Esim. seuraavassa <code>save_and_open_page</code> saattaa avata sivun, jossa ei vielä näy yhtään olutta:

``` ruby
  it "shows a known beer", js:true do
    visit beerlist_path
    save_and_open_page
    expect(page).to have_content "Nikolai"
  end
```

Kuten sivulla https://github.com/jnicklas/capybara#asynchronous-javascript-ajax-and-friends sanotaan, osaa capybara odottaa asynkroonisia javascript-kutsuja sen verran, että testien sivulta etsimät elementit ovat latautuneet.

Tiedämme, että javascriptin pitäisi lisätä sivun taulukkoon rivejä. Saammekin sivun näkymään oikein, jos lisäämme alkuun komennon <code>find('table').find('tr:nth-child(2)')</code> joka etsii sivulta taulukon ja sen sisältä toisen rivin (taulukon ensimmäinen rivihän on jo sivupohjassa mukana oleva taulukon otsikkorivi):

``` ruby
  it "shows a known beer", :js => true do
    visit beerlist_path
    find('table').find('tr:nth-child(2)')
    save_and_open_page    
    expect(page).to have_content "Nikolai"
  end
```

Nyt capybara odottaa taulukon valmistumista ja siirtyy sivun avaavaan komentoon vasta taulukon latauduttua (itseasiassa vain 2 riviä taulukkoa on varmuudella valmiina).

> ## Tehtävä 3
>
> Tee testi joka varmistaa, että oluet ovat beerlist-sivulla oletusarvoisesti nimen mukaan aakkosjärjestyksessä
>
> Testaaminen kannattaa tehdä nyt siten, että etsitään taulukon rivit <code>find</code>-selektorin avulla ja varmistetaan, että jokaisella rivillä on oikea sisältö. Koska taulukossa on otsikkorivi, löytyy ensimmäinen varsinainen rivi seuraavasti:
>
> find('table').find('tr:nth-child(2)').should have_content('Fastenbier')

> ## Tehtävä 4
>
> Tee testit seuraaville toiminnallisuuksille
> * klikattaessa saraketta 'style' järjestyvät oluet tyylin nimen mukaiseen aakkosjärjestykseen
> * klikattaessa saraketta 'brewery' järjestyvät oluet panimon nimen mukaiseen aakkosjärjestykseen

**Huom.** Travis ei osaa suoraan ajaa Selenium-testejä. Ongelmaan löytyy vastaus täältä  http://about.travis-ci.org/docs/user/gui-and-headless-browsers/#Using-xvfb-to-Run-Tests-That-Require-GUI-(e.g.-a-Web-browser)

## Bootstrap

Toistaiseksi emme ole kiinnittäneet ollenkaan huomiota sovelluksiemme ulkoasuun. Modernin ajattelun mukaan HTML-koodi määrittelee ainoastaan sivujen tietosisällön ja ulkoasu määritellään erillisissä CSS-tiedostoissa. 

Käytimme jo edellä HTML:ssä id:itä siihen, että pääsisimme javascriptissä käsiksi haluamiimme elementteihin. Id:iden lisäksi HTML:ssä merkataan elementtejä luokilla (class), jotta tyylitiedostojen määrittelemiä tyylejä saadaan ohjattua halutuille kohtiin sivua. 

Määrittelimme jo muutama viikko sitten, että application layoutiin sijoittamamme navigointipalkki sijaitsee div-elementisssä jolle on asetettu luokka "navibar":

```erb
<div class="navibar">
  <%= link_to 'breweries', breweries_path %>
  <%= link_to 'beers', beers_path %>
  <%= link_to 'styles', styles_path %>
  <%= link_to 'ratings', ratings_path %>
  <%= link_to 'users', users_path %>
  <%= link_to 'clubs', beer_clubs_path %>
  <%= link_to 'places', places_path %>
  |
  <% if not current_user.nil? %>
    <%= link_to current_user.username, current_user %>
    <%= link_to 'rate a beer', new_rating_path %>
    <%= link_to 'join a club', new_membership_path %>
    <%= link_to 'signout', signout_path, method: :delete %>
  <% else %>
    <%= link_to 'signin', signin_path %>
    <%= link_to 'signup', signup_path %>
  <% end %>
</div>
```

Määrittelimme viikolla 2 navigointipalkille tyylin lisäämällä hakemistossa app/assets/stylesheats/ sijaitsevaan tiedostoon application.css seuraavat:

```css
.navibar {
    padding: 10px;
    background: #EFEFEF;
}
```

CSS:ää käyttämällä koko sivuston ulkoasu voitaisiin muotoilla sivuston suunnittelijan haluamalla tavalla, jos silmää ja kykyä muotoiluun löytyy.

Sivuston muotoilunkaan suhteen ei onneksi ole enää tarvetta keksiä pyörää uudelleen. Bootstrap (vanhala nimetään Twitter Bootstrap) http://getbootstrap.com/ on "kehys", joka sisältää suuren määrän web-sivujen ulkoasun muotoiluun tarkoitettuja CSS-tyylitiedostoja ja javascriptiä. Bootstrap onkin noussut nopeasti suuureen suosioon web-sivujen ulkoasun muotoilussa. Otetaan bootstrap käyttöön sovelluksessamme sivun http://railsapps.github.io/twitter-bootstrap-rails.html ohjeita noudatellen.

Aloitetaan sitten sovelluksemme bootstrappaaminen gemin https://github.com/twbs/bootstrap-sass. Lisätään Gemfileen seuraavat:

```ruby
gem 'bootstrap-sass'
group :development do
  gem 'rails_layout'
end
```

Otetaan gemit käyttöön komennolla <code>bundle install</code>.

Generoidaan seuraavaksi sovellukselle Bootstrapin tarvitsemat tiedostot.
**Ota kuitenkin ensin talteen sovelluksen navigaatiopalkin generoiva koodi.** Suoritetaan sitten bootstrapin tarvitsemien tiedostojen generoidaan bootstrapin tarvitsevat tiedostot (mm. tiedoston application.html.erb ylikirjottavalla) komennolla

    rails generate layout:install bootstrap3 --force

Käynnistetään rails server uudelleen. Kun nyt avaamme sovelluksen selaimella, huomaamme jo pienen muutoksen esim. fonteissa. Myös navigointipalkki on hävinnyt.

Edellä suorittamamme komento on luonut navigointipalkkia varten hakemistoon app/views/layout tiedostot _navigation.html.erb ja _navigation_links.html.erb

Kuten arvata saattaa, navigointipalkkiin tulevat linkit sijoitetaan tiedostoon *_navigation_links.html.erb*. Jokainen linkki tulee sijoittaa li-tagin sisälle. Lisää tiedostoon seuraavat:  

```erb
<li><%= link_to 'breweries', breweries_path %></li>
<li><%= link_to 'beers', beers_path %></li>
<li><%= link_to 'styles', styles_path %></li>
<li><%= link_to 'ratings', ratings_path %></li>
<li><%= link_to 'users', users_path %></li>
<li><%= link_to 'clubs', beer_clubs_path %></li>
<li><%= link_to 'places', places_path %></li>
<% if not current_user.nil? %>
    <li><%= link_to current_user.username, current_user %></li>
    <li><%= link_to 'rate a beer', new_rating_path %></li>
    <li><%= link_to 'join a club', new_membership_path %></li>
    <li><%= link_to 'signout', signout_path, method: :delete %></li>
<% else %>
    <li><%= link_to 'signin', signin_path %></li>
    <li><%= link_to 'signup', signup_path %></li>
<% end %>
```

Sen lisäksi että Bootstrapilla voi helposti muodostaa navigointipalkin, joka pysyy jatkuvasti sivun ylälaidassa, voidaan Bootstrapin grid-järjestelmän avulla jakaa sivu erillisiin osiin, ks. http://getbootstrap.com/css/#grid

Muutetaan sovelluksen layoutin eli tiedoston application.html.erb sivupohjan renderöivää osaa seuraavasti:

```erb
  <body>
    <header>
      <%= render 'layouts/navigation' %>
    </header>
    
    <main role="main" class=".container">
      <%= render 'layouts/messages' %>

      <div class="row">
        <div class="col-md-8">
          <%= yield %>
        </div>
        <div class="col-md-4">
          <img src="http://www.cs.helsinki.fi/u/mluukkai/wadror/pint.jpg" width="200">
        </div>
      </div>

    </main>
  </body>
```

Eli sijoitamme bootstrapin containeriin yhden rivin, jonka jaamme kahteen sarakkeeseen: 9:n levyiseen johon kunkin sivun tiedot upotetaan ja 3:n levyiseen osaan jossa näytämme hienon kuvan.

Sivun pohja on nyt kunnossa ja voimme hyödyntää bootstrapin tyylejä ja komponentteja sivuillamme. 

Navigaatio määriteltiin jo *navbar*-komponentin ks. http://getbootstrap.com/components/#navbar avulla. 

Muotoillaan seuraavaksi hieman sivulla käyttämiämme taulukoita. Bootstrapin sivulta http://getbootstrap.com/css/#tables näemme, että taulukon normaali bootstrap-muotoilu saadaan käyttöön lisäämällä taulukon HTML-koodille luokka <code>table</code>, seuraavasti:

```erb
<table class="table">
  ...
</table>
```

Lisätään luokkamäärittely esim. oluiden sivulle ja kokeillaan. Näyttää jo paljon professionaalimmalta. Päätetään vielä lisätä luokka <code>table-hover</code>, jonka ansioista se rivi jonka kohdalla hiiri on muuttuu korostetuksi, eli taulukon luokkamäärittelyksi tulee

```erb
<table class="table table-hover">
  ...
</table>
```

> ## Tehtävä 5
>
> Muuta ainakin muutama sovelluksen taulukoista käyttämään bootstrapin tyylejä.
>
> 

Bootstrap tarjoaa valmiit tyylit myös painikkeille http://getbootstrap.com/css/#buttons

Päätetään käyttää luokkaparin <code>btn btn-primary</code> määrittelemää sinistä painiketta. Seuraavassa esimerkki, missä luokka on lisätty oluen reittauksen tekevälle painikkeelle:

```erb
  <h4>give a rating:</h4>

  <%= form_for(@rating) do |f| %>
    <%= f.hidden_field :beer_id %>
    score: <%= f.number_field :score %>
    <%= f.submit class:"btn btn-primary" %>
  <% end %>
```

Luokka voidaan lisätä myös niihin linkkeihin, jotka halutaan napin painikkeen näköisiksi:

```erb
<%= link_to 'New Beer', new_beer_path, class:'btn btn-primary' %>
```

> ## Tehtävä 6
>
> Lisää sovelluksen ainakin muutamille painikkeille ja painikkeen tapaan toimiville linkeille valitut tyylit. Poisto-operaatioissa tyyliksi kannattaa laittaa <code>btn btn-danger</code>. 


> ## Tehtävä 7
>
> Muuta navigointipalkkia siten, että käyttäjän kirjautuessa kirjautunutta käyttäjää koskevat toiminnot tulevat menupalkin dropdowniksi alla olevan kuvan tapaan.
>
> Ohjeita löydät dokumentista http://getbootstrap.com/components/#nav-dropdowns

![kuva](https://github.com/mluukkai/WebPalvelinohjelmointi2014/raw/master/images/ratebeer-w6-3.png)

## Asset pipeline

Rails-sovelluksiin liittyviä javascript- ja tyylitiedostoja hallitaan (ja kuvia) ns. Asset pipelinen avulla, ks. http://guides.rubyonrails.org/asset_pipeline.html

Periaatteena on se, että sovelluskehittäjä sijoittaa sovellukseen liittyvät javascript-tiedostot hakemistoon _app/assets/javascripts_ ja tyylitiedostot hakemistoon _app/assets/stylesheets_.  Molempia voidaan sijoittaa useaan eri tiedostoon, ja tarvittaessa alihakemistoihin. 

Sovellusta kehitettäessä (eli kun sovellus on ns. development-moodissa) Rails liittää kaikki (ns. manifest-tiedostossa) määritellyt javascript- ja tyylitiedostot mukaan sovellukseen. Huomaammekin tarkastellessamme sovellusta selaimen view source -ominaisuuden avulla, että mukaan on liitetty suuri joukko javascriptiä ja tyylitiedostoja.

Sovelluksen mukaan liitettävät javascript-tiedostot määritellään tiedostossa _app/assets/javascripts/application.js_, jonka sisältö on nyt seuraava

```javascript
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require bootstrap
//= require_tree .
```

Vaikka koko tiedoston sisältö näyttää olevan kommenteissa, on kuitenkin kyse "oikeista", asset pipelinestä huolehtivan [sprockets-kääntäjän](https://github.com/sstephenson/sprockets) komennoista, joiden avulla määritellään sovellukseen mukaan otettavat javascript-tiedostot. Neljä ensimmäistä riviä määrittelevät, että mukaan otetaan jquery, jquery_ujs, turbolinks ja bootstrap. Kaikki näistä on asennettu sovellukseen gemien avulla. 

Viimeinen rivi määrittelee, että kaikki hakemiston *assets/javascripts/* ja sen alihakemistojen sisältämät javascript-tiedostot sisällytetään ohjelmaan. 

Asset pipeline mahdollistaa myös [coffeescriptin](http://coffeescript.org/) käyttämisen, tällöin tiedostojen päätteeksi tulee <code>.js.coffee</code>. Sovellusta suoritettaessa scprockets kääntää coffeescriptin automaattisesti javascriptiksi.

Tuotantokäytössä sovelluksella ei suorituskykysyistä usein kannata olla useampia javascript- tai tyylitiedostoja. Kun sovellusta aletaan suorittaa tuotantoympäristössä (eli production-moodissa), sprockets yhdistääkin kaikki sovelluksen javascript- ja tyylitiedostot yksittäisiksi, optimoiduiksi tiedostoiksi. Huomaamme tämän jos katsomme herokussa olevan sovelluksen html-lähdekoodia, esim: http://wad-ratebeer.herokuapp.com/ sisältää se nyt ainoastaan yhden js- ja yhden css-tiedoston joista varsinkin js-tiedoston luettavuus on ihmisen kannalta heikko.

Lisää asset pipelinestä ja mm. javascriptin liittämisestä railssovelluksiin mm. seuraavissa:
* http://railscasts.com/episodes/279-understanding-the-asset-pipeline
* http://railsapps.github.io/rails-javascript-include-external.html

## Scopet

Osa panimoista on jo lopettanut toimintansa ja haluaisimme eriyttää lopettaneet panimot aktiivisten panimoiden listalta. Lisätään painimotietokantaan aktiivisuuden merkkaava boolean-arvoinen sarake. Luodaan migraatio:

    rails g migration AddActivityToBrewery active:boolean

Huom: koska migraation nimi alkaa sanalla Add ja loppuu olion nimeen Brewery, ja sisältää tiedon lisättävästä sarakkeesta, generoituu juuri oikea migraatiokoodi automaattisesti.

Suoritetaan migraatio ja käydään konsolista käsin merkkaamassa kaikki tietokannassa olevat panimot aktiiviseksi:

```ruby
irb(main):020:0> Brewery.all.each{ |b| b.active=true; b.save }
```

Käydään luomassa uusi panimo, jotta saamme tietokantaamme myös yhden epäaktiivisen panimon. 

Muutetaan sitten panimon sivua siten, että se kertoo panimon mahdollisen epäaktiivisuuden panimon nimen vieressä:

```erb
<p id="notice"><%= notice %></p>

<h2><%= @brewery.name %>
  <% if not @brewery.active  %>
      <span class="label label-info">retired</span>
  <% end %>
</h2>

<p> 
  <em>Established year:</em>
  <%= @brewery.year %>
</p>

<p>Number of beers <%= @brewery.beers.count%> </p>

<ul>
 <% @brewery.beers.each do |beer| %>
   <li><%= link_to beer.name, beer %></li>
 <% end %>
</ul>

<% if @brewery.ratings.empty? %>
    <p>beers of the brewery have not yet been rated! </p>
<% else %>
    <p>Has <%= pluralize(@brewery.ratings.count,'rating') %>, average <%= @brewery.average_rating %> </p>
<% end %>

<% if current_user %>
  <%= link_to 'Edit', edit_brewery_path(@brewery), class:"btn btn-primary"  %>
  <%= link_to 'Destroy', @brewery, method: :delete, data: { confirm: 'Are you sure?' }, class:"btn btn-danger"  %>
<% end %>
```

Panimon luomis- ja editointilomakkeeseen on syytä lisätä mahdollisuus panimon aktiivisuuden asettamiseen. Lisätään views/breweries/_form.html.erb:iin checkbox aktiivisuuden säätelyä varten:

```erb
  <div class="field">
    <%= f.label :active %>
    <%= f.check_box :active %>
  </div>
```

Kokeillaan. Huomaamme kuitenkin että aktiivisuuden muuttaminen ei toimi.

Syynä tälle on se, että attribuuttia <code>active</code> ei ole lueteltu  massasijoitettavaksi sallittujen attribuuttien joukossa. 

Tutkitaan hieman panimokontrolleria. Sekä uuden oluen luominen, että oluen tietojen muuttaminen hakevat olueen liittyvät tiedot metodin <code>brewery_params</code> avulla:

```ruby

  def create
    @brewery = Brewery.new(brewery_params)

    #…
  end

  def update
    # …
    if @brewery.update(brewery_params)
    #…
  end

  def brewery_params
    params.require(:brewery).permit(:name, :year)
  end
```

Kuten [viikolla 2 totesimme](
https://github.com/mluukkai/WebPalvelinohjelmointi2014/blob/master/web/viikko2.md#reittauksen-talletus) on jokainen massasijoitettavaksi tarkoitettu attribuutti eksplisiittisesti sallittava <code>permit</code> metodin avulla. Muuetaan metodia <code>brewery_params</code> seuraavasti:
```ruby
  def brewery_params
    params.require(:brewery).permit(:name, :year, :active)
  end
```

Päätetään, että haluamme näyttää panimoiden listalla erikseen aktiiviset ja epäaktiiviset panimot. Suoraviivainen ratkaisu on seuraava. Talletetaan kontrollerissa aktiiviset ja passiiviset omiin muuttujiinsa:

```ruby
  def index
    @active_breweries = Brewery.where(active:true)
    @retired_breweries = Brewery.where(active:[nil, false])
  end
```

Kentän <code>active</code>-arvo voi olla joko eksplisiittisesti asetettu <code>false</code> tai <code>nil</code> jotka molemmat tarkoittavat eläköitynyttä panimoa, olemme joutuneet lisäämään jälkimmäiseen <code>where</code>-lauseeseen molemmat vaihtoehdot.

Copypastetaan näkymään taulukko kahteen kertaan, erikseen aktiivisille ja eläköityneille:

```erb
<p id="notice"><%= notice %></p>

<h1>Breweries</h1>

<h2>Active</h2>

<p> Number of active breweries: <%= @active_breweries.count %> </p>

<table class="table table-hover">
  <thead>
    <tr>
      <th><%= link_to 'Name', breweries_path(order:"name") %></th>
      <th><%= link_to 'Year', breweries_path(order:"year") %></th>
    </tr>
  </thead>

  <tbody>
    <% @active_breweries.each do |brewery| %>
      <tr>
        <td><%= link_to brewery.name, brewery %></td>
        <td><%= brewery.year %></td>
        <td></td>
      </tr>
    <% end %>
  </tbody>
</table>

<h2>Retired</h2>

<p> Number of retired breweries: <%= @retired_breweries.count %> </p>

<table class="table table-hover">
  <thead>
  <tr>
    <th><%= link_to 'Name', breweries_path(order:"name") %></th>
    <th><%= link_to 'Year', breweries_path(order:"year") %></th>
  </tr>
  </thead>

  <tbody>
  <% @retired_breweries.each do |brewery| %>
      <tr>
        <td><%= link_to brewery.name, brewery %></td>
        <td><%= brewery.year %></td>
        <td></td>
      </tr>
  <% end %>
  </tbody>
</table>

<br>

<%= link_to 'New Brewery', new_brewery_path, class:"btn btn-primary"  %>
```

Ratkaisu on toimiva (kontrolleriin tehty muutos toki rikkoo panimoiden järjestämisen eri sarakkeiden suhteen), mutta siinä on parillakin tapaa parantamisen varaa. Parannellaan ensin kontrolleria. 

Kontrolleri siis haluaa listan sekä aktiivisista että jo lopettaneista panimoista. Kontrolleri myös kertoo kuinka nuo listat tietokannasta haetaan. 

Voisimme tehdä kontrollerista siistimmän, jos luokka <code>Brewery</code> tarjoaisi mukavamman rajapinnan panimoiden listan hakuun. ActiveRecord tarjoaa tähän mukavan ratkaisun, scopet, ks. http://guides.rubyonrails.org/active_record_querying.html#scopes

Määritellään nyt panimoille kaksi scopea, aktiiviset ja eläköityneet:

```ruby
class Brewery < ActiveRecord::Base
  include RatingAverage

  validates :name, presence: true
  validates :year, numericality: { less_than_or_equal_to: ->(_) { Time.now.year} }

  scope :active, -> { where active:true }
  scope :retired, -> { where active:[nil,false] }

  has_many :beers, :dependent => :destroy
  has_many :ratings, :through => :beers
end
```

Scope määrittelee luokalle metodin, joka palauttaa kaikki scopen määrittelevän kyselyn palauttamat oliot.

Nyt <code>Brewery</code>-luokalta saadaan pyydettyä kaikkien panimoiden lisäksi mukavan rajapinnan avulla aktiiviset ja lopettaneet panimot:

    Brewery.all      # kaikki panimot
    Brewery.active   # aktiiviset
    Brewery.retired  # lopettaneet

Kontrollerista tulee nyt elegantti:

```ruby
  def index
    @active_breweries = Brewery.active
    @retired_breweries = Brewery.retired
  end
```

Ratkaisu on luettavuuden lisäksi parempi myös olioiden vastuujaon kannalta. Ei ole järkevää laittaa kontrollerin vastuulle sen kertomista _miten_ aktiiviset ja eläköityneet panimot tulee hakea kannasta, sensijaan tämä on hyvin luontevaa antaa modelin vastuulle, sillä modelin rooli on nimenomaan toimia abstraktiokerroksena muun sovelluksen ja tietokannan välillä.

## Partiaalit

Siistitään seuraavaksi panimolistan näyttötemplatea. Templatessa on nyt käytännössä sama taulukko kopioituna kahteen kertaan peräkkäin. Eristämme taulukon omaksi __partiaaliksi__, eli näyttötemplateen upotettavaksi tarkoitetuksi näyttötemplaten palaksi, ks. http://guides.rubyonrails.org/layouts_and_rendering.html#using-partials. 

Annetaan partialille nimi views/breweries/_list.html.erb (Huom: partialien nimet ovat aina alaviiva-alkuisia!). Sisältö on seuraava:

```erb
<table class="table table-hover">
  <thead>
  <tr>
    <th><%= link_to 'Name', breweries_path(order:"name") %></th>
    <th><%= link_to 'Year', breweries_path(order:"year") %></th>
  </tr>
  </thead>

  <tbody>
  <% breweries.each do |brewery| %>
      <tr>
        <td><%= link_to brewery.name, brewery %></td>
        <td><%= brewery.year %></td>
        <td></td>
      </tr>
  <% end %>
  </tbody>
</table>
```

Partiaali viittaa nyt taulukkoon sijoitettavien panimoiden listaan nimellä <code>breweries</code>.

Kaikki panimot renderöivä template ainoastaan *renderöi partiaalin* ja lähettää sille renderöitävän panimolistan parametriksi:

```erb
<p id="notice"><%= notice %></p>

<h1>Breweries</h1>

<h2>Active</h2>

<p> Number of active breweries: <%= @active_breweries.count %> </p>

<%= render 'list', breweries: @active_breweries %>

<h2>Retired</h2>

<p> Number of retired breweries: <%= @retired_breweries.count %> </p>

<%= render 'list', breweries: @retired_breweries %>

<br>

<%= link_to 'New Brewery', new_brewery_path, class:"btn btn-primary"  %>

```

Panimoiden sivun template on nyt lähes silmiä hivelevä! 

> ## Tehtävä 8-9 (kahden tehtävän arvoinen)
>
> Ratings-sivumme on tällä hetkellä hieman tylsä. Muuta sivua siten, että sillä näytetään reittausten sijaan:
>* kolme reittausten keskiarvon perusteella parasta olutta ja  panimoa  
>* kolme eniten reittauksia tehnyttä käyttäjää
>* viisi viimeksi tehtyä reittausta.
>
> **Vihjeitä:** 
> Tee luokalle <code>Rating</code> scope <code>:recent</code>, joka palauttaa viisi viimeisintä reittausta. Scopen vaatimaan tietokantakyselyyn löydät apuja linkistä http://guides.rubyonrails.org/active_record_querying.html, ks. order ja limit. Kokeile ensin kyselyn tekoa konsolista!
>
> Parhaiden oluet ja panimot sekä innokkaimmat reittaajat kertovien scopejen teko ei onnistu yhtä helposti, sillä scopen palauttamat oliot pitäisi selvittää tietokantatasolla eli tarvittaisiin monimutkaista SQL:ää.
>
> Scopejen sijaan voit tehdä luokille <code>Brewery</code>, <code>Beer</code> ja <code>User</code> luokkametodit (eli Javan terminologiassa staattiset metodit), joiden avulla kontrolleri saa haluamansa panimot, oluet ja käyttäjät. Esim. panimolla metodi olisi suunilleen seuraavanlainen:
>
>```ruby
>class Brewery
>  # ...
>
>  def self.top(n)
>    sorted_by_rating_in_desc_order = Brewery.all.sort_by{ |b| -(b.average_rating||0) } 
>    # palauta listalta parhaat n kappaletta
>    # miten? ks. http://www.ruby-doc.org/core-2.1.0/Array.html
>  end
>end
>```
>
> Metodia käytetään nyt kontrollerista seuraavasti:
>
>```ruby
>  @top_breweries = Brewery.top 3
>```
>
> Huom: oluiden, tyylien  ja panimoiden <code>top</code>-metodit ovat oikeastaan copypastea ja moduuleja käyttämällä olisi mahdollista saada koodin määrittely siirrettyä yhteen paikkaan. Kun olet tehnyt viikon kaikki tehtävät voit yrittää siistiä koodisi!
>
> __Älä copypastaa näyttöjen koodia vaan käytä tarvittaessa partiaaleja.__ 

> ## Tehtävä 10
>
> Lisää reittausten sivulle myös parhaat kolme oluttyyliä

Reittausten sivu voi näyttää tehtävävien jälkeen esim. seuraavalta:

![kuva](https://github.com/mluukkai/WebPalvelinohjelmointi2014/raw/master/images/ratebeer-w6-4.png)

Sivun muotoiluun voi olla apua seuraavasta: http://getbootstrap.com/css/#grid-nesting


## Näyttöjen koodin siistiminen helpereillä

Viikolla 3 lisäsimme luokkaan <code>ApplicationController</code> metodin <code>current_user</code> jonka määrittelimme myös ns. helper-metodiksi

```ruby
class ApplicationController < ActionController::Base
  # ...
  helper_method :current_user

 end 
```

näin sekä kontrollerit että näkymät voivat tarvittaessa käyttää metodia kirjaantuneena olevan käyttäjän identiteetin tarkastamiseen. Koska metodi on määritelty luokkaan <code>ApplicationController</code> on se automaattisesti kaikkien kontrollerien käytössä. Helper-metodiksi määrittely tuo metodin myös näkymien käyttöön. 

Sovelluksissa on usein tarve kirjoittaa apumetodeja (eli Railsin terminologian mukaan helper-metodeja) pelkästään näyttötemplateja varten. Tällöin niitä ei kannata sijoittaa <code>ApplicationController</code>-luokkaan vaan hakemiston _app/helpers/_ alla oleviin moduuleihin. Jos apumetodia on tarkoitus käyttää useammasta näytöstä, on oikea sijoituspaikka <code>application_helper</code>, jos taas apumetodit ovat tarpeen ainoastaan yhden kontrollerin alaisuudessa olevilla sivuilla, kannattaa ne määritellä ko. kontrolleria vastaavaan helper-moduliin.

Huomaamme, että näyttöjemme koodissa on joitain toistuvia osia. Esim. oluen, tyylin ja panimon show.html.erb-templateissa on kaikissa hyvin samantapainen koodi, jolla sivulle luodaan tarvittaessa linkit editointia ja poistamista varten:

```erb
<% if current_user %>
  <%= link_to 'Edit', edit_style_path(@style) %> <td>
  <%= link_to 'Destroy', @style, method: :delete, data: { confirm: 'Are you sure?' } %></td>
<% end %>
```

Eriytetään nämä omaksi helperiksi, moduliin application_helper.rb

```ruby
module ApplicationHelper
  def edit_and_destroy_buttons(item)
    unless current_user.nil?
      edit = link_to('Edit', url_for([:edit, item]), class:"btn btn-primary")
      del = link_to('Destroy', item, method: :delete,
                    data: {confirm: 'Are you sure?' }, class:"btn btn-danger")
      raw("#{edit} #{del}")
    end
  end

end
```

Metodi muodostaa link_to:n avulla kaksi HTML-linkkielementtiä ja palauttaa molemmat "raakana" (ks. http://apidock.com/rails/ActionView/Helpers/RawOutputHelper/raw), eli käytännössä HTML-koodina, joka voidaan upottaa sivulle. 

Painikkeet lisätään esim. oluttyylin sivulle seuraavasti:

```erb
<p id="notice"><%= notice %></p>

<h2>
  <%= @style.name %>
</h2>

<quote>
  <%= @style.description %>
</quote>

...

<%= edit_and_destroy_buttons(@style) %>
```

Näytön muodostava template siistiytyykin huomattavasti. 

Painikkeet muodostava koodi olisi pystytty myös eristämään omaan partialiin, ja onkin hiukan makuasia kumpi on tässä tilanteessa parempi ratkaisu, helper-metodi vai partiali. 

> ## Tehtävä 11
>
> Usealla sovelluksen sivulla näytetään reittausten keskiarvoja. Keskiarvot ovat Decimal-tyyppiä, joten ne tulostuvat välillä hieman liiankin monen desimaalin tarkkuudella. Määrittele reittausten keskiarvon renderöintiä varten apumetodi <code>round(param)</code>, joka tulostaa aina parametrinsa __yhden__ desimaalin tarkkuudella, ja ota apumetodi käyttöön (ainakin joissakin) näyttötemplateissa. 
>
> Voit käyttää helpperissäsi esim. Railsista löytyvää <code>number_with_precision</code>-metodia, ks. http://api.rubyonrails.org/classes/ActionView/Helpers/NumberHelper.html#method-i-number_with_precision

## Reitti panimon statuksen muuttamiselle

Lisäsimme hetki sitten panimoille tiedon niiden aktiivisuudesta ja mahdollisuuden muuttaa panimon aktiivisuusstatusta panimon tietojen editointilomakkeesta. Kuvitellaan hieman epärealistisesti, että panimot voisivat vähän väliä lopettaa ja aloittaa jälleen toimintansa. Tällöin aktiivisuusstatuksen muuttaminen panimon tietojen editointilomakkeelta olisi hieman vaivalloista. Tälläisessä tilanteessa olisikin kätevämpää, jos esim. kaikkien panimoiden listalla olisi panimon vieressä nappi, jota painamalla panimon aktiivisuusstatuksen muuttaminen onnistuisi. Voisimme toteuttaa tälläisen napin upottamalla panimoiden listalle jokaisen panimon kohdalle sopivan lomakkeen. Teemme kuitenkin nyt toisenlaisen ratkaisun. Lisäämme panimoille Railsin oletusarvoisen kuuden reitin lisäksi uuden reitin <code>toggle_activity</code>, johon tehdyn HTTP POST -kutsun avulla panimon aktiivisuusstatusta voi muuttaa. 

Tehdään tiedostoon routes.rb seuraava muutos panimon osalta:

```ruby
  resources :breweries do
    post 'toggle_activity', on: :member
  end
```

Kun nyt teemme komennon <code>rake routes</code> huomaamme panimolle ilmestyneen uuden reitin:

```ruby
toggle_activity_brewery POST   /breweries/:id/toggle_activity(.:format) breweries#toggle_activity
              breweries GET    /breweries(.:format)                     breweries#index
                        POST   /breweries(.:format)                     breweries#create
            new_brewery GET    /breweries/new(.:format)                 breweries#new
           edit_brewery GET    /breweries/:id/edit(.:format)            breweries#edit
                brewery GET    /breweries/:id(.:format)                 breweries#show
                        PUT    /breweries/:id(.:format)                 breweries#update
                        DELETE /breweries/:id(.:format)                 breweries#destroy
```

Päätämme lisätä aktiivisuusstatuksen muutostoiminnon yksittäisen panimon sivulle. Eli lisätään panimon sivulle app/views/breweries/show.html.erb seuraava:

```erb
<%= link_to "change activity", toggle_activity_brewery_path(@brewery.id), method: :post, class: "btn btn-primary" %>
```

Kun nyt klikkaamme painiketta, tekee selain HTTP POST -pyynnön osoitteeseen /breweries/:id/toggle_activity, missä :id on sen panimon id, jolla linkkiä klikattiin. Railsin reititysmekanismi yrittää kutsua breweries-kontrollerin metodia <code>toggle_activity</code> jota ei ole, joten seurauksena on virheilmoitus. Metodi voidaan toteuttaa esim. seuraavasti:

```ruby
  def toggle_activity
    brewery = Brewery.find(params[:id])
    brewery.update_attribute :active, (not brewery.active)

    new_status = brewery.active? ? "active" : "retired"

    redirect_to :back, notice:"brewery activity status changed to #{new_status}"
  end
```

Tominnallisuuden toteuttaminen oli varsin helppoa, mutta onko reitin <code>toggle_activity</code> lisääminen järkevää? RESTful-ideologian mukaan puhdasoppisempaa olisi kenties ollut hoitaa asia lomakkeen avulla, eli polkuun breweries/:id kohdistuneella POST-pyynnöllä (tai tarkemmin ottaen PUT- -tai PATCH-pyynnöllä sillä kyse olemassaolevan resurssin muuttamisesta). Jokatapauksessa tulee välttää tilanteita, joissa resurssin tilaa muutettaisiin GET-pyynnöllä, ja tästä syystä määrittelimmekin polun toggle_activity ainoastaan POST-pyynnöille.

Lisää custom routeista sivulla
http://guides.rubyonrails.org/routing.html#adding-more-restful-actions

> ## Tehtävä 12-13 (kahden tehtävän arvoinen)
>
> ### Tehtävä on hieman työläs, joten tee ensin helpommat pois alta. Muut viikon tehtävät eivät riipu tästä tehtävästä.
>
> Toistaiseksi kuka tahansa voi sovelluksessamme liittyä olutkerhon jäseneksi. Muutetaan nyt sovellusta siten, että jäsenyys ei tule voimaan ennenkuin joku jo jäsenenä oleva vahvistaa jäsenyyden. 
>
> Muutamia huomioita
> * jäsenyyden vahvistamattomuus kannattaa huomioida siten, että Membership-modeliin lisätään boolean-arvoinen kenttä _confirmed_
> * Kun kerho luodaan, tee sen luoneesta käyttäjästä automaattisesti kerhon jäsen
> * Näytä kerhon sivulla jäsenille lista vahvistamattomana olevista jäsenyyksistä (eli jäsenhakemuksista)
> * Jäsenyyden statuksen muutos voidaan hoitaa esim. oman custom-reitin avulla 

Tehtävän jälkeen sovelluksesi voi näyttää esim. seuraavalta. Olutseuran sivulla näytetään lista jäsenyyttä hakeneista, jos kirjautuneena on olutseurassa jo jäsenenä oleva käyttäjä: 

![kuva](https://github.com/mluukkai/WebPalvelinohjelmointi2014/raw/master/images/ratebeer-w6-6.png)

Käyttäjän omalla sivulta näytetään toistaiseksi käsittelemättömät hakemukset:

![kuva](https://github.com/mluukkai/WebPalvelinohjelmointi2014/raw/master/images/ratebeer-w6-5.png)

## Indeksi tietokantaan

Kun käyttäjä kirjautuu järjestelmäämme, suoritetaan sessiokontrollerissa operaatio, jossa käyttäjäolio haetaan tietokannasta käyttäjän nimen perusteella:

```ruby
class SessionsController < ApplicationController
  def create
    user = User.find_by username: params[:username]

     # ...
  end

end
```

Operaation suorittamista varten tietokanta joutuu käymään läpi koko <code>users</code>-taulun. Haut olion id:n suhteen ovat nopeampia, sillä jokainen taulu on indeksöity id:iden suhteen. Indeksi toimii hajautustaulun tavoin, eli tarjoaa "O(1)"-ajassa toimivan pääsyn haettuun tietokannan riviin.

Tietokantojen tauluihin voidaan lisätä tarvittaessa muitakin indeksejä. Nopeutetaan <code>users</code>-taulusta tapahtuvaa käyttäjätunnuksen perusteella tehtävää hakua lisäämällä taululle indeksi. 

Luodaan indeksiä varten migraatio 

    rails g migration AddUserIndexBasedOnUsername

Migraatio on seuraavanlainen:

```ruby
class AddUserIndexBasedOnUsername < ActiveRecord::Migration
  def change
    add_index :users, :username
  end
end
```

Suoritetaan migraatio komennolla <code>rake db:migrate</code> ja indeksi on valmis!

Indeksin huono puoli on se, että kun järjestelmään lisätään uusi käyttäjä tai olemassaoleva käyttäjä poistetaan, on indeksi muodostettava uudelleen ja tähän luonnollisestsi kuluu aikaa. Indeksin lisäys on siis tradeoff sen suhteen, mitä operaatiota halutaan optimoida.

## Laiska lataaminen, n+1-ongelma ja tietokantakyselyjen optimointi

Kaikki oluet näyttävä kontrolleri on yksinkertainen. Oluet haetaan tietokannasta, järjestetään HTTP-kutsussa olleen parametrin määrittelemällä tavalla ja asetetaan templatea varten muuttujaan:

```ruby
  def index
    @beers = Beer.all

    order = params[:order] || 'name'

    case order
      when 'name' then @beers.sort_by!{ |b| b.name }
      when 'brewery' then @beers.sort_by!{ |b| b.brewery.name }
      when 'style' then @beers.sort_by!{ |b| b.style.name }
    end
  end
```

Template listaa oluet taulukkona:

```erb
<% @beers.each do |beer| %>
  <tr>
    <td><%= link_to beer.name, beer %></td>
    <td><%= link_to beer.style, beer.style %></td>
    <td><%= link_to beer.brewery.name, beer.brewery %></td>
  </tr>
<% end %>
</table>
```

Yksinkertaista ja tyylikästä... mutta ei kovin tehokasta. 


Voisimme katsoa lokitiedostosta log/development.log mitä kaikkea oluiden sivulle mentäessä tapahtuu. Pääsemme samaan tietoon hieman mukavammassa muodossa käsiksi _miniprofiler_ gemin (ks. https://github.com/MiniProfiler/rack-mini-profiler ja http://samsaffron.com/archive/2012/07/12/miniprofiler-ruby-edition)

Miniprofilerin käyttöönotto on helppoa, riittää että Gemfileen lisätään rivi

    gem 'rack-mini-profiler'

Suorita <code>bundle install</code> ja käynnistä rails server uudelleen. Kun menet tämän jälkeen osoitteeseen http:localhos:300/beers huomaat, että sivun yläkulmaan ilmestyy aikalukema joka kuvaa HTTP-pyynnön suoritukseen käytettyä aikaa. Numeroa klikkaamalla avautuu tarkempi erittely ajankäytöstä:

![kuva](https://github.com/mluukkai/WebPalvelinohjelmointi2014/raw/master/images/ratebeer-w6-7.png)

Raportti kertoo että <code>Executing action: index</code> eli kontrollerimetodin suoritus aiheuttaa yhden SQL-kyselyn <code>SELECT "beers".* FROM "beers"</code>. Sensijaan  
 <code>Rendering: beers/index</code> eli näkymätemplaten suoritus aiheuttaa peräti 9 SQL-kyselyä!

Kyselyjä klikkaamalla päästään tarkastelemaan syytä:

![kuva](https://github.com/mluukkai/WebPalvelinohjelmointi2014/raw/master/images/ratebeer-w6-7.png)

Näkymätemplaten renderöinti siis suorittaa useaan kertaan seuraavat kyselyt:

```ruby
SELECT  "breweries".* FROM "breweries"  WHERE "breweries"."id" = ?  ORDER BY "breweries"."id" ASC LIMIT 1  

SELECT  "styles".* FROM "styles"  WHERE "styles"."id" = ?  ORDER BY "styles"."id" ASC LIMIT 1 
```
Käytännössä jokaista erillistä olutta kohti tehdään oma kysely sekä <code>styles</code>- että <code>breweries</code> tauluun.

Syynä tälle on se, että activerecordissa on oletusarvoisesti käytössä ns. lazy loading, eli kun haemme olion tietokannasta, olioon liittyvät kentät haetaan tietokannasta vasta jos niihin viitataan. Joskus tämä käyttäytyminen on toivottavaa, olioonhan voi liittyä suuri määrä olioita, joita ei välttämättä tarvita olion itsensä käsittelyn yhteydessä. Kaikkien oluiden sivulle mentäessä lazy loading ei kuitenkaan ole hyvä idea, sillä tiedämme varmuudella että jokaisen oluen yhteydessä näytetään myös oluen panimon sekä tyylin nimet ja nämä tiedot löytyvät ainoastaan panimoiden ja tyylien tietokantatauluista.

Voimme ohjata ActiveRecordin metodien parametrien avulla kyselyistä generoituvaa SQL:ää. Esim. seuraavasti voimme ohjeistaa, että oluiden lisäksi niihin liittyvät panimot tulee hakea tietokannasta:

```ruby
  def index
    @beers = Beer.includes(:brewery).all
    # ...
  end
```

Miniprofilerin avulla näemme. että kontrollerin suoritus aiheuttaa nyt kaksi kyselyä:

```ruby
SELECT "beers".* FROM "beers"  
SELECT "breweries".* FROM "breweries"  WHERE "breweries"."id" IN (1, 2, 3, 6) 
```

Näyttötemplaten  suoritus aiheuttaa enää 5 kyselyä, jotka kaikki ovat muotoa:

```ruby

SELECT  "styles".* FROM "styles"  WHERE "styles"."id" = ?  ORDER BY "styles"."id" ASC LIMIT 1 
```

Näytön renderöinnin yhteydessä enää on haettava oluisiin liittyvät tyylit tietokannasta, kukin omalla SQL-kyselyllä.

Optimoidaan kontrolleria vielä siten, että myös kaikki tarvittavat tyylit luetaan kerralla kannasta:

```ruby
  def index
    @beers = Beer.includes(:brewery, :style).all

    # ...
  end
```

Kontrollerin suoritus aiheuttaa nyt kolme kyselyä ja näytön renderöinti ainoastaan yhden kyselyn. Miniprofiler paljastaa että kysely on

```ruby
SELECT  "users".* FROM "users"  WHERE "users"."id" = ? LIMIT 1
```

ja syynä sille on 

```ruby
app/controllers/application_controller.rb:10:in `current_user'
```
eli näytön muuttujan <code>current_user</code> avulla tekemä viittaus kirjautuneena olevaan käyttäjään. Tämä ei kuitenkaan ole hirveän vakavaa.

Saimme siis optimoitua SQL-kutsujen määrän 1+2n:stä (missä n tietokannassa olevien oluiden määrä) kolmeen (plus yhteen)!

Kokemaamme kutsutaan n+1-ongelmaksi (ks. http://guides.rubyonrails.org/active_record_querying.html#eager-loading-associations), eli hakiessamme kannasta yhdellä kyselyllä listallisen olioita, jokainen listan olioista aiheuttaakin salakavalasti uuden tietokantahaun ja näin yhden haun sijaan tapahtuukin noin n+1 hakua.

Muutetaan seuraavaa tehtävää varten kaikki käyttäjät listaava template  muotoon

```ruby
<h1>Users</h1>

<table class="table table-hover">
  <thead>
    <th> </th>
    <th> rated beers </th>
    <th> total ratings </th>
  </thead>
  <tbody>
    <% @users.each do |user| %>
      <tr>
        <td><%= link_to user.username, user %></td>
        <td><%= user.beers.size %></td>
        <td><%= user.ratings.size %></td>
      </tr>
    <% end %>
  </tbody>
</table>
```

> ## Tehtävä 14
>
> Muutos aiheuttaa n+1-ongelman käyäjien sivulle. Korjaa ongelma edellisen esimerkin tapaan eager loadaamalla tarvittavat oliot käyttäjien hakemisen yhteydessä. Varmista optimointisi onnistuminen miniprofilerilla. 

**Huom:** jos taulukkoon liitettäisi myös suosikkioluen kertova sarake
  
     <td><%= user.favorite_beer %></td>

Muuttuisi tilanne hieman hankalammaksi SQL:n optimoinnin suhteen. Metodimme viimeisin versio oli seuraava:

```ruby
  def favorite_beer
    return nil if ratings.empty?
    ratings.order(score: :desc).limit(1).first.beer
  end
```

Nyt edes eager loadaaminen ei auta, sillä metodikutsu auheuttaa joka tapauksessa SQL-kyselyn. Jos sensijaan toteuttaisimme metodin keskusmuistissa olueeseen liittyviä reittauksia (kuten teimme aluksi viikolla 4):

```ruby
  def favorite_beer
    return nil if ratings.empty?
    ratings.sort_by{ |r| r.score }.last.beer
  end
```

metodikutsu _ei_ aiheuttaisi tietokantaoperaatiota _jos_ reittaukset olisi eager loadattu siinä vaiheessa kun metodia kutsutaan.

Saattaakin olla, että metodista olisi tietyissä tilanteissa suorituskykyä optimoitaessa hyvä olla kaksi versiota, toinen joka suorittaa operaation tietokantatasolla ja toinen keskusmuistissa operaation tekevä.

## Cachays eli palvelinpuolen välimuistitoiminnallisuudet

Luodaan tietokantaamme hiukan lisää dataa. Kopioi seuraava tiedostoon db/seeds.db

```ruby
users = 200           # jos koneesi on hidas, riittää esim 100
breweries = 100       # jos koneesi on hidas, riittää esim 50
beers_in_brewery = 40
ratings_per_user = 30

(1..users).each do |i|
  User.create! username:"user_#{i}", password:"Passwd1", password_confirmation:"Passwd1"
end

(1..breweries).each do |i|
  Brewery.create! name:"brewery_#{i}", year:1900, active:true
end

bulk = Style.create name:"bulk", description:"cheap, not much taste"

Brewery.all.each do |b|
  n = rand(beers_in_brewery)
  (1..n).each do |i|
    beer = Beer.create! name:"beer #{b.id} -- #{i}"
    beer.style = bulk
    b.beers << beer
  end
end

User.all.each do |u|
  n = rand(ratings_per_user)
  beers = Beer.all.shuffle
  (1..n).each do |i|
    r = Rating.new score:(1+rand(50))
    beers[i].ratings << r
    u.ratings << r
  end
end
```

Käytämme tiedostossa normaalien olioiden luovien metodien <code>create</code>code> sijaan huutomerkillistä versiota <code>create!</code>code>. Metodien erona on niiden käyttäytyminen tilanteesa, jossa olion luominen ei onnistu. Huutomerkitön metodi palauttaa tällöin arvon <code>nil</code>, huutomerkillinen taas aiheuttaa poikkeuksen. Seedauksessa poikkeuksen aiheuttaminen on parempi vaihtoehto, muuten luomisen epäonnistuminen jää herkästi huomaamatta.

**Kopioi sitten vanha tietokanta _db/development.db_ talteen**, jotta voimme palata vanhaan tilanteeseen suorituskyvyn virittelyn jälkeen. Voimme ottaa vanhan tietokannan käyttöön muuttamalla sen nimeksi jälleen development.db

*Huom:* tämä ei ole välttämättä paras mahdollinen tapa tehdä suorituskykytestausta oikeille Rails-sovelluksille, ks. lisää tietoa seuraavasta http://guides.rubyonrails.org/v3.2.13/performance_testing.html (guidesta ei ole Rails 4:lle päivitettyä versiota.)

Suorita seedaus komennolla 

    rake db:seed

Skriptin suorittamisessa kuluu tovi.

Nyt tietokannassamme on runsaasti dataa ja sivujen lataaminen alkaa olla hitaampaa.

Kokeile nyt miten sivujen suorituskykyyn vaikuttaa jos kommentoit pois äsken tekemäsi SQL-kyselyjen optimoinnit oluiden sivulta, eli muuta olutkontrolleri takaisin muotoon:

```ruby
  def index
   # @beers = Beer.includes(:brewery, :style).all
    @beers = Beer.all

    order = params[:order] || 'name'

    case order
      when 'name' then @beers.sort_by!{ |b| b.name }
      when 'brewery' then @beers.sort_by!{ |b| b.brewery.name }
      when 'style' then @beers.sort_by!{ |b| b.style.name }
    end
  end
```

Huomioi myös suoritettujen SQL-kyselyjen määrä optimoinnilla ja ilman. Tuloksenhan näet jälleen kätevästi miniprofilerin avulla.

Kokeilun jälkeen voit palauttaa koodin optimoituun muotoon.

Datamäärän ollessa suuri, ei pelkkä kyselyjen optimointi riitä, vaan on etsittävä muita keinoja.

Vaihtoehdoksi nousee tällöin cachaus eli välimuistien käyttö. 

Web-sovelluksessa cachaystä voidaan suorittaa sekä selaimen, että palvelimen puolella. Tarkastellaan nyt palvelimen puolella tapahtuvaa cachaystä. Toteutimme jo viime viikollä "käsin" beermapping-apista haettujen tietojen cachaystä Rails.cachen avulla. Tutkitaan nyt muutamaa hieman automaattisempaa cachaysmekanismia.

Rails tarjoaa palvelinpuolen cachaystä kolmella tasolla:
* kokonaisten sivujen cachays (page cache)
* kontrollerin metodien tulosten cachays (action cache)
* sivufragmenttien cachays (fragment cache)

Ks. http://guides.rubyonrails.org/caching_with_rails.html

Rails 4:ssä kaksi ensimmäistä edellisistä on poistettu Railsin coresta mutta ne saadaan tarvittaessa käyttöön erillisten gemien avulla. Tutustummekin nyt ainoastaan viimeiseen eli sivufragmenttien cachaamiseen joka onkin cachaysstrategioista monipuolisin.

Tutustutaan näistä kahteen käytetyimpään, ja aloitetaan kontrollerin metodien cachayksestä eli action cachayksetä.

Cahays ei ole oletusarvoisesti päällä kun sovellusta suoritetaan development-moodissa. Saat cachayksen päälle muuttamalla tiedostosta _config/environment/development.rb_ seuraavan rivin arvoksi <code>true</code>:

    config.action_controller.perform_caching = false

Käynistä nyt sovellus uudelleen.

Päätetään cachata oluiden listan näyttäminen. 

Fragmentticachays tapahtuu sisällyttämällä näkymätemplaten cachattavan osa seuraavanlaiseen lohkoon:

```erb
<% cache 'avain', skip_digest: true do %>
  cachättävä näkymätemplaten osa
<% end %>
```

Kuten arvata saattaa, <code>avain</code> on avain jolla cachattava näkymäfragmentti talletetaan. Avaimena voi olla merkkijono tai olio .<code>skip_digest: true</code> liittyy [näyttötemplatejen versiointiin](http://blog.remarkablelabs.com/2012/12/russian-doll-caching-cache-digests-rails-4-countdown-to-2013) jonka haluamme nyt jättää huomioimatta. Tämä kuitenkin tarkoittaa, että välimuisti on syytä tyhjentää (komennolla <code>Rails.cache.clear</code>) _jos_ näkymätemplaten koodia muutetaan.

Fragmentticachayksen lisääminen oluiden listalle views/beers/index.html on helppoa, cachataan sivulta sen dynaminen osa eli oluiden taulukko:

```erb
<h1>Listing beers</h1>

<% cache 'beerlist', skip_digest: true do %>

    <table class="table table-hover">
      <thead>
      <tr>
        <th> <%= link_to 'Name', beers_path(order: "name") %> </th>
        <th> <%= link_to 'Style', beers_path(order: "style") %> </th>
        <th> <%= link_to 'Brewery', beers_path(order: "brewery") %> </th>
      </tr>
      </thead>

      <tbody>
      <% @beers.each do |beer| %>
          <tr>
            <td><%= link_to beer.name, beer %></td>
            <td><%= link_to beer.style, beer.style %></td>
            <td><%= link_to beer.brewery.name, beer.brewery %></td>
          </tr>
      <% end %>
      </tbody>
    </table>

<% end %>
<br>

<%= link_to 'New Beer', new_beer_path, class: "btn btn-primary" if current_user %>
```

Kun nyt menemme sivulle, ei sivufragmenttia ole vielä talletettu välimuistin ja sivun lataaminen kestää yhtä kauan kuin ennen cachayksen lisäämistä:

![kuva](https://github.com/mluukkai/WebPalvelinohjelmointi2014/raw/master/images/ratebeer-w6-9.png)

Sivun renderöimiseen kulunut aika <code>Rendering: beers/index</code> oli siis 814 millisekuntia.

Sivulla käytyämme fragmentti tallettuu välimuistiin ja seuraava sivun avaaminen on huomattavasti nopeampi:

![kuva](https://github.com/mluukkai/WebPalvelinohjelmointi2014/raw/master/images/ratebeer-w6-10.png)

Eli näkymätemplate renderöityy kolmessa millisekunnissa!

Huom: uuden oluen luomislinkkiä ei kannata laittaa cachatyn fragmentin sisälle, sillä linkki tulee näyttää ainoastaan kirjautuneille käyttäjille. Sivun cachatty osa näytetään nyt kaikille samanlaisena.

Jos luomme nyt uuden oluen huomaamme, että uuden oluen tietoja ei tule sivulle. Syynä tälle on tietenkin se, että sivufragmentti löytyy edelleen välimuistista. Vanhentunut näkymäfragmentti tulisi siis ekspiroida. Tässä tapauksessa helpoin strategia on kontrollerista käsin tapahtuva manuaalinen ekspirointi. 

Ekspirointi tapahtuu komennolla <code>expire_fragment(avain)</code> jota tulee siis kutsua kontrollerista niissä kohdissa joissa oluiden listan sisältö mahdollisesti muuttuu. Tälläisiä kohtia ovat olutkontrollerin metodit <code>create</code>, <code>update</code> ja <code>destroy</code>. Muutos on helppo:

```erb
  def create
    expire_fragment('beerlist')
  end

  def update
    expire_fragment('beerlist')
    # ...
  end

  def destroy
    expire_fragment('beerlist')
    # ...
  end
```

Muutosten jälkeen sivu toimii odotetulla tavalla!

Kaikkien oluiden sivua olisi mahdollista nopeuttaa vielä jonkin verran. Nyt nimittäin kontrolleri suorittaa tietokantaoperaation

```erb
    @beers = Beer.includes(:brewery, :style).all
```

myös silloin kun sivufragmentti löytyy välimuistista. Voisimmekin testata fragmentin olemassaoloa metodilla <code>fragment_exist?</code> ja suorittaa tietokantaoperaation ainoastaan jos fragmentti ei ole olemassa (muistutus: unless tarkoittaa samaa kuin if not):

```erb
  def index 
    unless fragment_exist?( 'beerlist' )
      @beers = Beer.includes(:brewery, :style).all

      order = params[:order] || 'name'

      case order
        when 'name' then @beers.sort_by!{ |b| b.name }
        when 'brewery' then @beers.sort_by!{ |b| b.brewery.name }
        when 'style' then @beers.sort_by!{ |b| b.style.name }
      end
    end
  end
```

Kontrolleri näyttää hieman ikävältä, mutta sivu nopeutuu entisestään:

![kuva](https://github.com/mluukkai/WebPalvelinohjelmointi2014/raw/master/images/ratebeer-w6-11.png)

Voisimme siistiä ratkaisua aavistuksen palauttamalla metodin <code>index</code> ennalleen ja tarkastamalla fragmentin olemassaolon esifiltterissä:

```ruby
  before_action :skip_if_cached, only:[:index]

  def skip_if_cached
    return render :index if fragment_exist?( 'beerlist' )
  end
```

Jos esifiltteri <code>skip_if_cached</code> huomaa, että fragmentti on olemassa, se renderöi näkymätemplaten suoraan. Tässä tapauksessa varsinaista kontrollerimetodia ei suoriteta ollenkaan.


Huomaamme kuitenkin että sivulla on pieni ongelma. Oluet sai järjestettyä sarakkeita klikkaamalla vaihtoehtoisiin järjestyksiin. Cachays on kuitenkin rikkonut toiminnon! 

Yksi tapa korjata toiminnallisuus on liittää fragmentin avaimeen järjestys:

```erb
<% cache "beerlist-#{@order}", skip_digest: true do %>
   taulukon html
<% end %>
```

Järjestys talletetaan siis muuttujaan <code>@order</code> kontrollerissa. Seuraavassa kontrollerin vaatimat muutokset: 

```ruby
  def skip_if_cached
    @order = params[:order] || 'name'
    return render :index if fragment_exist?( "beerlist-#{params[:order]}"  )
  end

  def index
    @beers = Beer.includes(:brewery, :style).all

    case @order
      when 'name' then @beers.sort_by!{ |b| b.name }
      when 'brewery' then @beers.sort_by!{ |b| b.brewery.name }
      when 'style' then @beers.sort_by!{ |b| b.style.name }
    end
  end
```

eli koska kontrollerimetodia ei välttämättä suoriteta, tallettaa esifiltteri järjestyksen.

Ekspiroinnin yhteydessä on ekspiroitava kaikki kolme järjestystä:

```ruby
   ["beerlist-name", "beerlist-brewery", "beerlist-style"].each{ |f| expire_fragment(f) } 
```

**Huom:** voit kutsua fragmentticachen operaatioita konsolista:

```ruby
irb(main):043:0> ActionController::Base.new.fragment_exist?( 'beerlist-name' )
Exist fragment? views/beerlist-name (0.4ms)
=> true
irb(main):044:0> ActionController::Base.new.expire_fragment( 'beerlist-name' )
Expire fragment views/beerlist-name (0.6ms)
=> true
irb(main):045:0> ActionController::Base.new.fragment_exist?( 'beerlist-name' )
Exist fragment? views/beerlist-name (0.1ms)
=> nil
```

> ## Tehtävä 15
>
> Toteuta panimot listaavalle sivulle fragmentticashays. Varmista, että sivun sisältöön vaikuttava muutos ekspiroi cachen.

Jos haluaisimme cachata yksittäisen oluen sivun, kannattaa fragmentin avaimeksi laittaa itse cachattava olio:

```ruby
<% cache @beer do %>

    <h2>
      <%= @beer.name %>
    </h2>

    <p>
      <%= link_to @beer.style, @beer.style %>
      brewed by
      <%= link_to @beer.brewery.name, @beer.brewery %>
    </p>

    <% if @beer.ratings.empty? %>
        <p>beer has not yet been rated! </p>
    <% else %>
        <p>Has <%= pluralize(@beer.ratings.count,'rating') %>, average <%= round(@beer.average_rating) %> </p>
    <% end %>

<% end %>

<!- cachaamaton osa >

<% if current_user %>

    <h4>give a rating:</h4>

    <%= form_for(@rating) do |f| %>
        <%= f.hidden_field :beer_id %>
        score: <%= f.number_field :score %>
        <%= f.submit class:"btn btn-primary"  %>
    <% end %>

    <p></p>

<% end %>

<%= edit_and_destroy_buttons(@beer) %>
```

Nyt fragmentin avaimeksi tulee merkkijono, jonka Rails generoi kutsumalla olion metodia <code>cache_key</code>. Metodi generoi avaimen joka yksilöi olion _ja_ sisältää aikaleiman, joka edustaa hetkeä, jolloin olio on viimeksi muuttunut. Jos olion kenttiin tulee muutos, muuttuu fragmentin avaimen arvo eli vanha fragmentti ekspiroituu automaattisesti. Seuraavassa esimerkki automaattisesti generoituvasta cache-avaimesta:

```ruby
irb(main):006:0> b = Beer.first
irb(main):006:0> b.cache_key
=> "beers/1-20140106210715764510000"
irb(main):014:0> b.update_attribute(:name, 'ISO 4')
irb(main):015:0> b.cache_key
=> "beers/1-20140211200158000903000"
```

Ratkaisu on vielä sikäli puutteellinen, että jos olueeseen tehdään uusi reittaus, olio ei itsessään muutu ja fragmentti ei ekspiroidu. Ongelma on kuitenkin helppo korjata. Lisätään reittaukseen tieto, että reittauksen syntyessä, muuttuessa tai tuhoutuessa, on samalla 'kosketettava' reittaukseen liittyvää olutta:

```ruby
class Rating < ActiveRecord::Base
  belongs_to :beer, touch: true
 
  # ...
end
```

Käytännössä <code>belongs_to</code>-yhteyteen liitetty <code>touch: true</code> saa aikaan sen, että yhteyden toisessa päässä olevan olion kenttä <code>updated_at</code> päivittyy.

> ## Tehtävä 16
>
> Toteuta yksittäisen panimon sivulle fragmentticachays. Huomaa, että edellisen esimerkin tapaan panimon sivufragmentin on ekspiroiduttava automaattisesti jos panimon oluisiin tulee muutoksia.

## Selainpuolen cachays

Cachaysta harjoitetaan monilla tasoilla, myös selainpuolella. Suosittelen aiheesta kiinnostuneille Codeschoolin videota _etag_ien käytöstä Rails-sovelluksissa, ks. http://rails4.codeschool.com/videos

Codeschoolin muutkin Rails 4 -videot ovat erittäin suositeltavia!

## Eventual consistency

Sovelluksen käyttäjän kannalta ei ole aina välttämätöntä, että sovelluksen näyttämä tilanne on täysin ajantasalla. Esim. ei ole kriittistä, jos reittausstatistiikkaa näyttävä ratings-sivu näyttää muutaman minuutin vanhan tilanteen, pääasia on, että kaikki järjestelmään tullut data tulee ennen pitkää näkyville käyttäjille. Tälläisestä hieman löyhemmästä ajantasaisuusvaatimuksesta, jolla saatetaan pystyä tehostamaan sovelluksen suorituskykyä huomattavasti käytetään englanninkielistä nimitystä [__eventual consistency__](http://en.wikipedia.org/wiki/Eventual_consistency).

Eventual consistensy -mallin mukainen ajantasaisuus on helppo määritellä Railsissa laittamalla esim. fragmentticachelle expiroitumisaika:

```erb
<% cache 'fragment_name', expires_in:10.minutes do %>
  ...
<% end %>
```

Tämä yksinkertaistaa sovellusta myös siinä mielessä, että cachen ekspiroiminen on helppoa, kun ei ole pakko huomioida kaikkia yksittäisiä kohtia koodissa, jotka voisivat aiheuttaa sivun epäajantasaisuuden.

Oletetaan, että järjestelmällämme olisi todella paljon käyttäjiä ja reittauksia tapahtuisi useita kertoja minuutissa. Jos haluaisimme näyttää ratings-sivulla täysin ajantasaista tietoa, ei sivun suorituskyky olisi hyvä, sillä jokainen oluen reittaus muuttaa sivun tilaa, ja sivu tulisi ekspiroida erittäin usein. Tämä taas tekisi cachayksestä lähes hyödyttömän.

SQL:n optimointi ja cachayskään eivät vielä tee ratings-sivusta kovin nopeita, sillä kontrollerin käyttämät operaatiot esim. <code>User.top(3)</code> vaativat käytännössä melkein koko tietokannan datan läpikäyntiä. Jos haluaisimme optimoida sivua vielä enemmän, tulisi meidän käyttää järeämpiä keinoja. Esim <code>User.top</code>-komennon suoritus nopeutuisi huomattavasti, jos käyttäjän reittausten määrä talletettaisiin suoraan käyttäjä-olioon, eli sen laskeminen ei edellyttäisi käyttäjään liittyvien Rating-olioiden lukumäärän laskemista. Tämä taas edellyttäisi, että aina käyttäjän uuden reittauksen yhteydessä päivitettäisiin myös käyttäjä-olioa. Eli itse reittausoperaation suoritus hidastuisi hieman.

Toinen ja ehkä parempi tapa reittaussivun nopeuttamiselle olisi cachata Rails.cacheen kontrollerin tarvitsemat tiedot. Kontrolleri on siis seuraava

```ruby
  def index
    @top_beers = Beer.top(3)
    @top_breweries = Brewery.top(3)
    @top_styles = Style.top(3)
    @most_active_users = User.most_active(3)
    @recent_ratings = Rating.recent
    @ratings = Rating.all
  end
```

Voisimme toimia nyt samoin kuin viikolla 5 kun talletimme olutravintoloiden tietoja Railsin cacheen, eli kontrolleri muuttuisi suunnilleen seuraavaan muotoon:

```ruby
  def index
    Rails.cache.write("beer top 3", Beer.top(3)) if cache_does_not_contain_data_or_it_is_too_old
    @top_beers = Rails.cache.read "beer top 3"
 
    # ...
  end
```

Kurssin tehtäväkirjanpitosovelluksen etusivu http://wadrorstats2014.herokuapp.com/ toimii tällä hetkellä melko nopeasti vaikka sivulla näytetäänkin kaikista järjestelmään tehdyistä palautuksista koostetut tilastot. Palautuksia on tällä hetkellä 510. Etusivun suorituskyky ei muuttuisi oikeastaan ollenkaan vaikka palautuksia olisi satakertainen määrä.

Sovellus tallettaa jokaisen palautuksen <code>Submission</code>-olioon. Jos etusivun generoinnin yhteydessä palautustilastot laskettaisiin käymällä läpi kaikki <code>Submission</code>-oliot, olisi sivun renderöinti huomattavasti hitaampaa, ja se hidastuisi sitä mukaa kun järjestelmään tulisi enemmän palautuksia. 

Sovellus toimii kuitenkin siten, että jokaisen viikon palautustilastot on esilaskettu <code>WeekStatistic</code>-olioihin. Sovellus päivittää viikkostatistiikkaa jokaisen uuden tai päivitetyn palautuksen yhteydessä. Tämä hidastaa palautuksen tekoa mariginaalisesti (operaatiossa pullonkaulana on sähköpostin lähetys, lähetykseen kuluu 95% operaation vievästä ajasta), mutta nopeuttaa etusivun lataamista todella paljon. Eli viikolla 6 etusivun tiedot saadaan generoitua kuuden olion perusteella ja oliot saadaan tietokannasta yhdellä SQL-kyselyllä ja käytännössä etusivun generointi on suorituskyvyltään täysin riippumaton tehtyjen palautusten määrästä.

Sovelluksen koodi löytyy osoitteesta 
https://github.com/mluukkai/wadrorstats

Sovellusten suorituskyvyn optimointi ei ole välttämättä helppoa, se edellyttää monentasoisia ratkaisuja ja pitää useimmiten tehdä tilannekohtaisesti räätälöiden. Koodi muuttuu yleensä optimoinnin takia rumemmaksi.

## Asynkronisuus, viestijonot ja taustatyöt

Yhtenä negatiivisena puolena cachen ajoittain tapahtuvassa ekspiroimisessa, esim. jos noudattaisimme strategiaa ratings-sivun suhteen, aiheutuu jollekin käyttäjälle aika ajoin paljon aikaavievä operaatio siinä vaiheessa kun data on generoitava uudelleen välimuistiin. 

Parempaan ratkaisuun päästäisiinkin jos käyttäjälle tarjottaisiin aina niin ajantasainen data kuin mahdollista, eli kontrolleri olisi muotoa:

```ruby
  def index
    @top_beers = Rails.cache.read "beer top 3"
 
    # ...
  end
```

Välimuistin päivitys voitaisiin sitten suorittaa omassa taustalla olevassa, aika ajoin heräävässä säikeessä/prosessissa:

```ruby
  def background_worker
    while true do
       sleep 10.minutes
       Rails.cache.write("beer top 3", Beer.top(3))
       Rails.cache.write("brewery top 3", Brewery.top(3))
       # ...
    end
  end
```

Ylläesitellyn kaltainen taustaprosessointitapa on siinä mielessä yksinkertainen, että sovelluksen ja taustaprosessointia suorittavan säikeen/prosessin ei tarvitse synkronoida toimintojaan. Toisinaan taas taustaprosessoinnin tarpeen laukaisee jokin sovellukselle tuleva pyyntö. Tällöin sovelluksen ja taustaprosessoijien välisen synkronoinnin voi hoitaa esim. viestijonojen avulla. 

Viestijonoilla ja erillisillä prosesseilla tai säikeillä hoidetun taustaprosessoinnin toteuttamiseen Railsissa on paljon erilaisia vaihtoehtoja. Yleisimmät lienevät _Delayed job_, _Resque_ ja _Sidekiq_ ks. esim.:

* https://github.com/collectiveidea/delayed_job
* [Delayed job Rails cast](http://www.youtube.com/watch?v=xVW4wRwwfJg)
* https://github.com/resque/resque
* http://railscasts.com/episodes/271-resque
* http://railscasts.com/episodes/366-sidekiq

Ennen Rails 4:sta Rails-sovellukset toimivat oletusarvoisesti yksisäikeisinä. Tästä taas oli seurauksena se, että sovellus käsitteli HTTP-pyynnöt peräkkäin (ellei palvelinohjelmiston tasolla oltu määritelty että sovelluksesta on käynnissä useampia instansseja, ks. esim. https://devcenter.heroku.com/articles/rails-unicorn). Rails 4:stä asti jokaisen pyynnön käsittely omassa säikeessään on oletusarvoisesti sallittu. On kuitenkin huomattava, että Railsin oletusarvoinen palvelinohjelmisto WEBrick _ei_ tue säikeistettyä pyyntöjen käsittelyä. Jos säikeistykselle on tarvetta, tulee palvelinohjelmistona käyttää [Pumaa](http://puma.io/). Puman käyttöönotto on [helppo tehdä](https://discussion.heroku.com/t/using-puma-on-heroku/150).

Lisää säikeistettyjen Rails-sovellusten tekemisestä [Rails-castista] (https://www.cs.helsinki.fi/i/mluukkai/365-thread-safety.mp4). Huomaa, että säikeistyksen sallimisen jälkeen on huolehdittava siitä että koodi on säieturvallista!
 

> ## Tehtävä 17
>
> Nopeuta ratings-sivun toimintaa. Voit olettaa, että käyttäjät ovat tyytyväisiä eventual consistency -mallin mukaiseen tiedon ajantasaisuuteen. Jos haluat voit käyttää taustaprosessointikirjastoja, mutta se ei ole tarpeen, ainakaan Herokuun deployaamista ei tarvita. Kirjoita ratings-kontrollerin <code>index</code>-metodiin pieni selitys nopeutusstrategiastasi jos se ei ole koodin perusteella muuten ilmeistä.

## Sovelluksen koostaminen palveluista

Sovelluksen suorituskyvyn skaalaaminen onnistuu vain tiettyyn pisteeseen asti, jos sovellus on monoliittinen, kokonaan yhden tietokannan varassa, yhdellä palvelimella suoritettava kokonaisuus. Sovellusta voidaan toki optimoida ja sitä voidaan skaalata __horisontaalisesti__ eli palvelimen fyysisiä resursseja kasvattamalla.

Parempaan skaalautuvuuteen päästään kuitenkin __vertikaalisella__ skaalautuvuudella, eli sensijaan että palvelimen fyysisiä resursseja yritettäisiin kasvattaa, otetaankin sovelluksen käyttöön useita palvelimia, jotka suorittavat sovelluksen toimintoja rinnakkain. Vertikaalinen skaalaaminen ei välttämättä onnistu triviaalisti, sovelluksen arkkitehtuuria on mukautettava. Jos sovellusta palvelee edelleen ainoastaan yksi tietokanta, voi siitä tuolla pullonkaula vertikaalisesta skaalaamisesta huolimatta, erityisesti jos kyseessä on relaatiotietokanta, joiden hajauttaminen ja näin ollen vertikaalinen skaalaaminen ei ole helppoa.

Sovelluksen skaalaaminen (ja joissain tapauksissa myös sen ylläpitäminen ja laajentaminen) on helpompaa, jos sovellus on koostettu useammista erillisistä itsenäisenä toimivista keskenään esim. HTTP-protokollalla kommunikoivista __palveluista__. Sovelluksemme itseasiassa hyödyntää jo toista palvelua eli BeermappingAPI:a. Vastaavasti sovelluksen toiminnallisuutta voitaisiin laajentaa integroimalla siihen uusia palveluja.

Jos haluaisimme esim. että sovelluksemme tekisi käyttäjälle suosikkioluttyyleihin ja sijaintiin (joka saadaan selvitettyä esim. käyttäjän tekemien HTTP-kutsujen IP-osotteen perusteella, ks http://www.iplocation.net/) perustuvia ruokareseptisuosituksia, kannattaisi suosittelijasta tehdä kokonaan oma palvelunsa. Sovelluksemme keskustelisi sitten palvelun kanssa HTTP-protokollaa käyttäen. 

Jos haluaisimme vastaavasti että sovelluksemme näyttäisi käyttäjälle olutsuosituksia käyttäjän oman suosikkityylin perusteella, olisi tämän toiminnallisuuden eriyttäminen omaksi, erillisellä palvelimella toimivaksi palveluksi hieman haastavampaa, sillä suositukset todennäköisesti riippuisivat muiden ihmisten tekemistä reittauksista ja tähän tietoon käsillepääsy taas edellyttäisi olutsuosittelijalta pääsyä sovelluksemme tietokantaan. Eli jos oluiden suosittelija haluttaisiin toteuttaa omana erillisenä palvelunaan, olisi sovelluksemme rakennetta kenties mietittävä kokonaan uudelleen, jotta tieto reittauksista saataisiin jaettua ratebeer-sovelluksen ja olutsuosituspalvelun kesken.

## Single sign on

Monilla sivustoilla on viime aikoina yleistynyt käytäntö, jossa mahdollistetaan sivulle kirjautuminen esim. Google- tai Facebook-tunnuksilla. Sivustot siis ovat ulkoistaneet käyttäjänhallinnan ja autentikoinnin erillisille palveluille.

Autentikointi tapahtuu OAuth2-standardia (ks. https://tools.ietf.org/html/draft-ietf-oauth-v2-31) hyödyntäen, OAuth-autentikoinnin perusteista enemmän esim. osoitteessa http://aaronparecki.com/articles/2012/07/29/1/oauth2-simplified

OAuth-pohjainen autentikaatio onnistuu Railsilla helposti Omniauth-gemejen avulla, ks. http://www.omniauth.org/ Jokaista palveluntarjoajaa kohti on nykyään olemassa oma geminsä, esim. omniauth-facebook https://github.com/mkdynamic/omniauth-facebook

> ## Tehtävä 18
>
> Lisää sovellukseen mahdollisuus käyttää sitä Facebook-tunnuksilla. Katso ensin railscast osoitteesta
http://railscasts.com/episodes/360-facebook-authentication ja kokeile sitten muutosten tekemistä. Facebookin developer-sivu näyttää nykyään hieman erilaiselta kuin castin tekohetkellä. Toiminnassakin on pientä eroavaisuutta, mm. sovellus on luotaessa oletusarvoisesti eristystilassa (sandbox-mode). Allaolevasta kuvasta näet paikan mihin **site URL** (eli http://localhost:3000) tulee määritellä 
>
> Integraation hoitavaa Facebook-sovellusta ei ole pakko julkaista, riittää että se toimii eristystilassa ja pelkästään omalla koneellasti
>
> Tarvisemasi muutokset eivät ole täysin suoraviivaisia:
> * Rails 4:ssä routes.rb-tiedostossa on match-metodin sijaan käytettävä eksplisiittisesti HTTP-pyynnön nimiä, tällä kertaa oikea vaihtoehto on <code>get</code>
> * joudut laajentamaan <code>User</code>-modelia siten, että sen avulla hoidetaan sekä järjestelmän omaa salasanaa hyödyntävät käyttäjät, että Facebookin kautta kirjautuvat 
> * tällä hetkellä <code>User</code>-olioiden validoinnissa vaaditaan, että olioilla on vähintään 4 merkin mittainen salasana. Joudut tekemään validoinnin ehdolliseksi, siten ettei sitä vaadita Facebookin tunnuksilla kirjautuvalta käyttäjältä katso apua googlella, tai toinen vaihtoehto on generoida myös Facebookin kautta kirjautuville esim. satunnainen salasana
> * <code>User</code>-olioiden validoinnissa vaaditaan, myös että usernamen pituus on korkeintaan 15 merkkiä. Tämä saattaa muodostaa ongelman jos haluat luoda usernamen Facebook-kirjautujan nimestä. Kasvata käyttäjätunnuksen maksimipituutta tarvittaessa.

![kuva](https://github.com/mluukkai/WebPalvelinohjelmointi2014/raw/master/images/ratebeer-w6-12.png)

## NoSQL-tietokannat

Relaatiotietokannat ovat dominoineet tiedon tallennusta jo vuosikymmenten ajan. Viime aikoina on kuitenkin alkanut jälleen tapahtumaan tietokantarintamalla, ja kattotermin NoSQL alla kulkevat "ei relaatiotietokannat" ovat alkaneet nostaa suosiotaan. 

Yhtenä motivaationa NoSQL-tietokannoilla on ollut se, että relaatiotietokantoja on vaikea skaalata massivisten internetsovellusten vaatimaan suorituskykyyn. Toisaalta myös tiettyjen NoSQL-tietokantojen skeemattomuus tarjoaa sovellukselle joustavuutta verrattuna SQL-tietokantojen tarkastimääriteltyihin tietokantaskeemoihin.

NoSQL-tietokantoja on useita, keskenään aivan erilaisilla toimintaperiaatteilla toimivia, mm.
* avain/arvotietokannat (key-value databases)
* dokumenttitietokannat (document databases)
* saraketietokannat (columnar databases)  
* verkkotietokannat (graph databases)

Jo meille tutuksi tullut <code>Rails.cache</code> on oikeastaan yksinkertainen avain-arvotietokanta, joka mahdollistaa mielivaltaisten olioiden tallettamisen avaimeen perustuen. Tietokannasta haku on rajoittunut hakuun avaimien perusteella ja tietokanta ei tue kannassa olevien olioiden välisiä liitoksia ollenkaan.

Uusien tietokantatyyppien noususta huolimatta relaatiotietokannat tulevat kuitenkin säilymään ja on todennäköistä että isommissa sovelluksissa on käytössä rinnakkain erilaisia tietokantoja, ja kuhunkin talletustarkoitukseen pyritään valitsemaan tilanteeseen parhaiten sopiva tietokantatyyppi, ks.
http://www.martinfowler.com/bliki/PolyglotPersistence.html

> ## Tehtävä 19
>
> Kurssi on tehtävien osalta ohi ja on aika antaa kurssipalaute osoitteessa https://ilmo.cs.helsinki.fi/kurssit/servlet/Valinta

## Tehtävien palautus

Commitoi kaikki tekemäsi muutokset ja pushaa koodi Githubiin. Deployaa myös uusin versio Herokuun.

Tehtävät kirjataan palautetuksi osoitteeseen http://wadrorstats2014.herokuapp.com/

Tehtävien palauttaminen on mahdollista vasta 17.2.

## Mitä seuraavaksi?

Jos Rails kiinnostaa, kannattaa tutustumista jatkaa esim. seuraaviin suuntiin

* https://leanpub.com/tr4w The Kirja. Kannattaa __ehdottomasti__ hankkia ja lukea kannesta kanteen
* http://guides.rubyonrails.org/ Paljon hyvää asiaa...
* http://railscasts.com/ erinomaisia yhteen teemaan keskittyviä videoita. Uusia videoita ei valitettavasti ole tullut moneen kuukauteen, toivottavasti aktivoituu vielä. Useimmat maksulliset pro-episodit näköjään löytyvät youtubesta...
* https://www.ruby-toolbox.com/ apua gemien etsimiseen
* [Eloquent Ruby](http://www.amazon.com/Eloquent-Ruby-Addison-Wesley-Professional-Series/dp/0321584104) erinomainen kirja Rubystä.
