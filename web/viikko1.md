## Web-sovellusten toimintaperiaatteita


Web-sovellusten toimintaperiaate on periaatteessa yksinkertainen. Käyttäjä avaa selaimen ja kirjoittaa osoiteriville haluamansa sivun URL:in, esim. http://www.cs.helsinki.fi/opiskelu/index.html. URL:in ensimmäinen osa, eli esimerkissämme www.cs.helsinki.fi on yleensä DNS-nimi, jonka avulla pystytään selvittämään www-sivua hallinnoivan palvelimen osoite. Selain lähettää web-palvelimelle pyynnön sivusta käyttäen HTTP-protokollan GET-metodia. Jos DNS-osoite on oikea, ja sivupyynnön lähettäjällä on oikeus URL:n polun määrittelemään resurssiin (esimerkissämme opiskelu/index.html), palvelin palauttaa selaimelle statuskoodin 200 ja sivun sisällön HTML-muodossa. Selain renderöi sitten sivun käyttäjälle. Jos sivua ei ole olemassa, palvelin palauttaa selaimelle virheestä kertovan statuskoodin 404. 

Palvelimen palauttama www-sivu voi olla __staattinen__, eli "käsin" palvelimella sijaitsevaan html-tiedostoon kirjoitettu tai __dynaaminen__, eli esim. palvelimen tietokannassa olevan datan perusteella generoitu. Esim. sivulla http://www.cs.helsinki.fi/courses oleva kurssien lista luetaan tietokannasta ja sivun renderöivä html-koodi muodostetaan aina uudelleen sivulle mentäessä, senhetkisen tietokannassa olevan kurssien listan perusteella.

Toisinaan www-sivuilla tiedon kulun suunta muuttuu ja dataa lähtetetään selaimelta palvelimelle. Useimmiten tämä tapahtuu siten, että sivustolla on lomake, jolle käyttäjä syöttää palvelimelle lähetettävät tiedot. Tietojen lähettämistä varten HTTP-protokolla tarjoaa metodin POST (myös HTTP:n GET-metodia voi käyttää tietojen lähettämiseen, tämä ei kuitenkaan ole suositeltavaa).  Esim. laitoksen www-sivujen yläkulmassa on lomake "Hae tältä sivustolta", jonka avulla sivun käyttäjä voi lähettää web-palvelimelle dataa. Kun käyttäjä painaa nappia "hae", selain lähettää palvelimelle http://www.cs.helsinki.fi POST-metodilla varustetun pyynnön, jonka mukana lähetetään käyttäjän lomakkeelle kirjoittama merkkijono. Palvelin vastaa lomakkeen lähetyksen yhteydessä tehtäviin POST-kutsuihin useimmiten palauttamalla uuden HTML-tiedoston, jonka selain sitten renderöi käyttäjälle. (Todellisuudessa POST-kutsuihin ei yleensä vastata palauttamalla html-sivua, vaan suoritetaan ns. uudelleenohjaus renderöitävän http-koodin sisältävälle sivulle ks. http://en.wikipedia.org/wiki/Post/Redirect/Get asiasta tarkemmin toisella viikolla)

HTTP-pyyntöihin ja vastauksiin liittyy osoitteen, datan (eli viestin rungon, engl. body) ja [statuskoodien](http://en.wikipedia.org/wiki/List_of_HTTP_status_codes) lisäksi myös otsikoissa eli __headereissä__ lähetettyä dataa (ks. 
http://en.wikipedia.org/wiki/List_of_HTTP_header_fields), jonka avulla tarkennetaan pyyntöjä ja niihin liittyviä vastauksia, esim. määritellään minkä tyyppistä dataa selain on valmis vastaanottamaan.

Web-palvelinohjelmoinnilla tarkoitetaan juuri niitä toimia, miten web-palvelin muodostaa selaimelle näytettäviä web-sivuja ja käsittelee selaimen lomakkeen avulla lähettämää käyttäjän syöttämää dataa.

Web-sivut eivät ole nykyään pelkkää html:ää. Html:nä pyritään kuvaamaan sivujen rakenne ja tietosisältö. Sivujen muotoilu on tapana hoitaa CSS-tyylitiedostojen avulla, ks. http://en.wikipedia.org/wiki/Cascading_Style_Sheets. Nykyään trendinä on myös sisällyttää www-sivuille yhä suurempi määrä __selaimessa__ suoritettavaa ohjelmakoodia, joka taas on javascriptiä. On hieman veteen piirretty viiva, mitä toiminnallisuuksia kannattaa toteuttaa selaimen päässä ja mitä palvelimella. Esim. jos www-sivu sisältää lomakkeen, jonka avulla suoritetaan sivustolle kirjautuminen, on selvää että salasanan ja käyttäjätunnuksen tarkastamisen täytyy tapahtua palvelimella. Sen sijaan selaimen päässä voidaan javascriptillä tehdä tarkistus onko käyttäjän salasanakenttä tyhjä kun käyttäjä yrittää kirjautua sivulle. Tälläisessä tilanteissa on turha vaivata palvelinta ollenkaan, sillä kirjautuminen ei tulisi kuitenkaan onnistumaan.

Viimeaikaisena trendinä on ollut pyrkiä saamaan web-sovellusten toiminta muistuttamaan mahdollisimman suuressa määrin normaalien työpöytäsovellusten toimintaa. Hyvänä esimerkkinä tälläisestä sovelluksesta on Google drive joka "matkii" mahdollisimman tarkasti wordin/openofficen toiminnallisuutta. Tälläisissä sovelluksissa sovelluslogiikasta suurin osa on toteutettu selaimessa. Palvelimessa toteutettua toiminnallisuutta tarvitaan kuitenkin aina, muutenhan tietoa ei voi jakaa sovellusta eri paikoissa käyttävien kesken. Kun moderneissa sovelluksisssa palvelimelta haetaan dataa, ei palvelin välttämättä palautakaan valmista HTML-sivua, vaan ainoastaan raakamuotoista dataa (yleensä json-muotoista), jonka selaimessa suoritettava javascript-koodi sitten sijoittaa käyttäjälle näytettävälle sivulle. Näin sivuista päivittyy ainoastaan tarpeellinen osa.

Tällä kurssilla keskitymme lähes yksinomaan web-sovellusten palvelinpuolen toiminnallisuuden toteuttamiseen. Viikolla 6 näemme muutaman esimerkin selaimen päässä javascriptillä toteutettavasta toiminnallisuudesta sekä sovelluksen ulkoasun muotoilusta CSS:n avulla.

Kurssilla kaikki tehtävät ovat upotettu tähän materiaaliin. Seuraavaa tehtävää lukuunottamatta kaikki tehtävät tullaan palauttamaan githubin kautta. github-palautusten lisäksi tehtävät merkataan tehdyksi tehtäväkirjanpitojärjestelmään. Tästä enemmän sivun lopussa. Aloitetaan kuitenkin nyt ensimmäisellä tehtävällä. 

> ## Tehtävä 1: HTTP in action
> 
> Erityisesti selainpuolen toiminnallisuuden toteuttamisessa selaimien developer-työkalut ovat erittäin tärkeä työskentelyväline. Selaimista kehittäjäystävällisin on chrome, ja oletamme tässä että käytät chromea. Vastaava toiminnallisuus löytyy muistakin selaimista. 
>
> Avaa chromen developer tool painamalla yhtä aikaa Shift, Control ja i. Pääset developer tooliin myös valikon Tools-kautta. Avaa välilehti Network. Välilehti näyttää selaimen lähettämät HTTP-pyynnöt ja palvelimen niihin lähettämät vastaukset.
>
> Copypastaa selaimen osoiteriville http://www.cs.helsinki.fi/courses ja paina enter.
> Ylimpänä näet sivun pyynnön aiheuttaneen GET-pyynnön. Avaa se (klikkaamalla kutsua) ja tutki mitä kaikkea pyynnön mukana menee. Tutki erityisesti headereja ja response-osaa. Developer tools näyttää erikseen pyyntöön liittyvät (request headers) ja vastaukseen liittyvät (response headers) headerit. 
>
> Pyyntö palauttaa siis välilehdellä response näytettävän HTML-koodin. Koodi sisältää viitteitä css-tyylitiedostoihin, javascript-tiedostoihin sekä kuviin. Sivua renderöitäessä selain hakee kunkin näistä omalla GET-pyynnöllä.
>
> Pidä edelleen sama networking-välilehti auki. Tyhjennä välilehti painamalla vasemman alareunan halkaistu pallo -symbolia. Kirjoita jotain "hae tältä sivustolta"-lomakkeelle ja paina nappia "hae". Lomakkeen tietojen lähetys palvelimelle tapahtuu HTTP-protokollan POST-metodin sisältävän pyynnön avulla.
>
> Tutki POST-pyynnön sisältöä (listalla ylimpänä). Huomaat Headereista, että pyyntöön vastattiin statuskoodilla 302, joka taas tarkoittaa sitä että palvelin tekee selaimelle __uudelleenohjauksen__, eli pyytää selainta menemään vastauksen headereissa ilmoittamaan osoitteeseen. POST-pyynnön vastaus ei siis sisällä ollenkaan HTML-koodia jonka selain voisi renderöidä käyttäjälle. Heti POST-kutsun perään selain tekeekin automaattisesti GET-kutsun POST:in vastauksen headerissa __Location__ olevaan osoitteeseen. Vasta tämän uudelleenohjauksen aiheuttaman pyynnön vastauksena tullut sivu renderöidään käyttäjälle.
>
> Tutki vielä joillekin muille sivuille tekemien pyyntöjen aiheuttamaa HTTP-protokolan viestintää.

## Ruby on Railsin perusteita

Tällä kurssilla käytämme Web-sovellusten toteuttamiseen Ruby on Rails -sovelluskehystä. 

Rails-sovellukset noudattavat MVC-mallia (tai WebMVC:tä, joka poikkeaa hiukan alkuperäisestä MVC:stä), jossa  ideana on jakaa sovelluksen data- ja sovelluslogiikka (Model), näyttöjen muodostaminen (View) ja toiminnan koordinointi (Controller) selkeästi eriytettyihin osiin. Lähes kaikki moderni Web-kehitys nykyään tapahtuu MVC-periaatetta noudattaen. MVC:n lisäksi moderneissa web-sovelluksissa on tosin myös kerrosarkkitehtuurien ja palveluperustaisien arkkitehtuurien (SOA) piirteitä.

Tutkitaan mitä tapahtuu kun käyttäjä menee Railsilla toteutetulle web-sivulle, olkoon sivun URL esim. http://myratebeer.herokuapp.com/breweries, eli kurssin aikana tekemämme esimerkkisovelluksen sivu, joka listaa kaikki esimerkkisovelluksen tuntemat panimot.

![mvc-kuva](http://www.cs.helsinki.fi/u/mluukkai/rails_mvc.png)

1. käyttäjän kirjoitettua URL:n selaimen osoiteriville, tekee selain HTTP GET-pyynnön palvelimelle myratebeer.herokuapp.com

2. palvelimella pyörivä web-palvelinohjelmisto (esim. Apache) ohjaa pyynnön osoitteeseen rekisteröityyn Rails-sovellukseen. Sovellus selvittää mikä sovelluksen kontrolleri on rekisteröity huolehtimaan resurssiin breweries kohdistuvia GET-kutsuja. Tätä vaihetta sanotaan Rails-sovelluksen sisäiseksi reititykseksi (routing), eli etsitään "reitti minkä varrella pyyntö käsitellään".

3. kun oikea kontrolleri (esimerkissämme panimoista huolehtiva kontrolleri) ja sen metodi selviää, kutsuu sovellus metodia ja antaa sille parametriksi HTTP-pyynnön mukana mahdollisesti tulleen datan. kontrolleri hoitaa sitten operaatioon liittyvät toimenpiteet, yleensä toimenpiteiden suorittaminen edellyttää joihinkin sovelluksen dataa ja sovelluslogiikkaa sisältäviin modeleihin tapahtuvaa metodikutsua.  

4. esimerkissämme kontrolleri pyytää panimoista huolehtivaa model-olioa lataamaan kaikkien panimoiden listan tietokannasta. 

5. saatuaan kaikkien oluiden listan, kontrolleri pyytää oluiden listan muodostavaa näkymää renderöimään itsensä

6. näkymä renderöityy eli kontrolleri saa kaikki oluet listaavan HTML-sivun 

7. kontrolleri palauttaa HTML-sivun web-palvelimelle

8. ja web-palvelin palauttaa generoidun HTML-sivun ja siihen liittyvät headerit selaimelle

MVC-mallissa modelit ovat useimmiten olioita, joiden tila talletetaan tietokantaan. Tietokannan käsittely on yleensä abstrahoitu siten, että ohjelmakoodin tasolla on harvoin tarve kirjoittaa SQL-kieltä tai tietokannan konfiguraatioita. Detaljit hoituvat Object Relational Mapping (ORM) -kirjaston avulla. Railsissa käytettävä ORM on nimeltään ActiveRecord, joka toimii hieman eri tavalla kuin joillekin ehkä tutut Javamaailmasta tutut JPA-standardia noudattavat EclipseLink ja Hibernate.

Railsin taustalla on vahvana periaatteena __convention over configuration__, mikä tarkoitaa tapaa, jolla Rails pyrkii minimoimaan konfiguraatioiden tekemisen tarpeen määrittelemällä joukon konventioita esim. tiedostojen nimennälle ja niiden sijainnille tiedostohierarkiassa. Tulemme pian näkemään mitä CoC-periaate tarkoittaa käytännössä sovellusohjelmoijan kannalta. Rails mahdollistaa toki konventiosta poikkeamisen, mutta siinä tapauksessa ohjelmoijan on konfiguroitava asioita käsin. 

Railsilla sovellusten tekeminen edellyttää luonnollisesti jonkinasteista Rubyn hallintaa. Ruby on dynaamisesti tyypitetty tulkattu oliokieli. Ruby-koodia ei siis käännetä ollenkaan, vaan tulkki suorittaa koodia komento komennolta. Koska kääntäjää ei ole, ilmenevät myös koodiin tehdyt syntaksivirheet vasta ajon aikana toisin kuin käännettävillä kielillä. Modernit kehitysympäristöt auttavat hiukan, tarjoten jonkin verran lennossa tapahtuvaa "syntaksitarkastusta", mutta kehitysympäristön tuki ei ole läheskään samaa luokkaa kuin esim. Javalla.

> ## Tehtävä 2: Rubyn alkeet
>
> Tee/käy läpi seuraavat
> * http://tryruby.org/levels/1/challenges/0
> * http://www.ruby-lang.org/en/documentation/quickstart/

## Kurssin suoritusmuoto

Kurssin rakenne poikkeaa jossain määrin laitoksen kurssistandardista. Kurssilla tehdään ainoastaan yksi sovellus, samaa sovellusta tehdään sekä teoriamateriaalissa että teorian sekaan upotetuissa laskareissa. Kurssin teoriamateriaalia ei pystykään pelkästään lukemaan; Materiaalia seuratessa tulee itse rakentaa matkan varrella täydentyvää sovellusta, sillä muuten tehtävien tekeminen on mahdotonta. Toisin sanoen **kurssia on seurattava tasaisesti koko kuuden viikon ajan**.

Jokaisen viikon deadlinen (sunnuntai klo 23.59) jälkeen julkaistaan edellisen viikon esimerkkivastaus. Seuraavalla viikolla on mahdollista jatkaa joko oman sovelluksen rakentamista tai ottaa pohjaksi edellisen viikon esimerkkivastaus.

Osa viikon tehtävistä on käytännössä pakollisia, muuten eteneminen pysähtyy viikon osalta. Osa tehtävistä taas on vapaaehtoisia, eikriittisten ominaisuuksien toteutuksia. Osa näistä ominaisuuksista oletetaan olevan ohjelmistossa seuraavalla viikolla, joten jos et ole tehnyt kaikkia viikon tehtäviä, kannattaa aloittaa esimerkkivastauksesta tai vaihtoehtoisesti copypasteta sieltä tarvittavat asiat koodiisi.

## Railsin asennus

Asennusohje osoitteessa https://github.com/mluukkai/WebPalvelinohjelmointi2014/wiki/railsin-asennus

## Sovelluksen luominen

Teemme kurssilla olutharrastajille tarkoitetun palvelun, jonka avulla olutharrastajat voivat selata olemassa olevia panimoja, oluita, oluttyylejä sekä "reitata" juomiaan oluita (eli antaa oluille oman mieltymyksensä mukaisen pistemäärän). Viikon 6 jälkeen sovellus näyttää suunilleen seuraavalta http://vast-castle-2613.herokuapp.com/ 

Rails tarjoaa sovelluskehittäjän avuksi useita generattoreita (ks. http://guides.rubyonrails.org/generators.html), joiden avulla on helppo generoida hieman valmista toiminnallisuutta sisältäviä tiedostopohjia.

Uusi Rails-sovellus luodaan generaattorilla new. Mene sopivaan hakemistoon ja luo sinne sovellus nimeltään ratebeer antamalla komentoriviltä komento 

    rails new ratebeer

Syntyy sovelluksen sisältämä hakemisto ratebeer. 

Huom: jatkon kannalta on kätevintä, että luodusta hakemistosta tehdään git-repositorio. Älä siis sijoita sovellusta minkään muun git-repositorion sisälle!

Siirry hakemistoon. Komennolla <code>tree</code> saat tuntumaa siitä, mitä kaikkea new-generaattorin suorittaminen sai aikaan. Huom: OSX:ssä ei ole oletusarvoisesti asennettuna tree-komentoa. Saat asennettua treen [homebrew:llä](http://brew.sh/) komennolla <code>brew install tree</code>

Seuraavassa hieman lyhennelty näkymä:

<pre>
mbp-18:ratebeer mluukkai$ tree
├── Gemfile
├── Gemfile.lock
├── README.rdoc
├── Rakefile
├── app
│   ├── assets
│   │   ├── images
│   │   ├── javascripts
│   │   │   └── application.js
│   │   └── stylesheets
│   │       └── application.css
│   ├── controllers
│   │   ├── application_controller.rb
│   │   └── concerns
│   ├── helpers
│   │   └── application_helper.rb
│   ├── mailers
│   ├── models
│   │   └── concerns
│   └── views
│       └── layouts
│           └── application.html.erb
├── bin
├── config
│   ├── application.rb
│   ├── boot.rb
│   ├── database.yml
│   ├── environment.rb
│   ├── environments
│   ├── initializers
│   ├── locales
│   └── routes.rb
├── config.ru
├── db
│   └── seeds.rb
├── lib
├── log
├── public
├── test
├── tmp
└── vendor
</pre>

Hakemistoista tärkein on sovelluksen ohjelmakoodin sisältävä **app**. Hakemiston **config** alla on erilaista sovelluksen konfigurointiin liittyvää dataa, mm. routes.rb, joka määrittelee miten sovellus käsittelee erilaiset sille kohdistuneet HTTP-pyynnöt. Tietokannan konfiguraatiot tulevat hakemistoon **db**. Gemfile taas määrittelee sovelluksen käyttämät kirjastot. Tulemme pikkuhiljaa tutustumaan sovelluksen hakemiston rakenteeseen tarkemmin. 

Hakemistorakenne on tärkeä osa Railsin Convention over Configuration -periaatetta, jokaiselle komponentille (esim. panimoista huolehtivalle kontrollerille) on oma tarkasti määritelty paikkansa, josta Rails osaa etsiä komponentin ilman että sovelluskehittäjän tarvitsee erikseen kertoa railsille missä hakemistossa ja tiedostossa komponentti sijaitsee.

Käynnistä sovellus antamalla komentoriviltä komento

    rails server

Saman asian ajaa lyhennetty muoto rails s

Komento käynnistää oletusarvoisesti WEBrick HTTP-palvelimen (ks. http://en.wikipedia.org/wiki/WEBrick), joka alkaa suorittamaan hakemistossa olevaa Rails-sovellusta paikallisen koneen (eli localhost:in) portissa 3000.

Huom: saatat törmätä tässä vaiheessa virheeseen joka johtuu siitä että koneellasi ei ole javascript-suoritusympäristöä. Yksi tapa kiertää ongelma on listätä tiedostoon Gemfile seuraava rivi (tai riittää poistaa # tiedostossa jo valmiina olevan rivin edestä):

    gem 'therubyracer', platforms: :ruby

ja suorittaa komentoriviltä komento <code>bundle install</code>

Kokeile selaimella osoitteessa [http://localhost:3000](http://localhost:3000) että sovellus on käynnissä.

HUOM: **Tarkoituksena on, että tätä dokumenttia lukiessasi teet koko ajan samat asiat itse omaan sovellukseesi kuin mitä tässä dokumentissa esimerkkisovellukselle tehdään**. Osa toteutettavista asioista on muotoiltu tehtäviksi, kuten seuraava kohta, ja osa askelista taas tulee tehdä, jotta materiaalissa eteneminen on ylipäätään mahdollista.

> ## Tehtävä 3
> 
> Talletamme kurssilla tehtävän sovelluksen Githubissa sijaitsevaan repositorioon. 
>
> Tee sovelluksesi hakemistosta git-repositorio suorittamalla hakemistossa komento <code>git init</code> 
>
> Luo sovellusta varten repositorio Githubiin ja liitä se etärepositorioksi sovelluksesi hakemiston repositorioon 
>
> Ohjeita gitin ja Githubin käyttöön https://github.com/mluukkai/WebPalvelinohjelmointi2014/wiki/versionhallinta
>
> Tämän dokumentin lopussa on ohje varsinaisen palautuksen tekemiseksi

Aloitetaan sovelluksen rakentaminen. Päätetään aloittaa panimoista, eli:
* luodaan tietokantataulu panimoita varten
* tehdään toiminnallisuus, joka listaa kaikki panimot
* tehdään toiminnallisuus, joka mahdollistaa uuden panimon lisäyksen
* saamme myös kaupan päälle toiminnallisuuden panimon tietojen muuttamiseen ja panimon poistamiseen

Railsissa konventiona on, että (melkein) jokaista tietokantaan talletettavaa luokkaa varten solvelluksessa on oma model-luokka, kontrolleri-luokka sekä joukko omia näytön muodostavia tiedostoja.

Luodaan kaikki nämä Railsin valmista scaffold-generaattoria käyttäen. Panimolla on nimi (merkkijono) ja perustusvuosi (kokonaisluku). Anetaan komentoriviltä (sovelluksen sisältävästä hakemistosta) seuraava komento:

    rails generate scaffold brewery name:string year:integer

Syntyy melkoinen määrä tiedostoja. Tärkeimmät näistä ovat
* app/model/Brewery.rb 
* app/controllers/breweries_controller.rb
* app/views/breweries/index.html.erb 
* app/views/breweries/show.html.erb 
* views-hakemistoon tulee näiden lisäksi muutama muukin tiedosto.

Railsin scaffold-generaattori luo siis kaikki tarvittavat tiedostopohjat nimettyinä ja sijoiteltuna Railsin konvention mukaisesti.

Loimme koodin generaattorilla <code>rails g scaffold brewery name:string year:integer</code>. Generaattorissa kirjoitimme luotavan asian, eli panimotietokantataulun ja siihen liittyvät asiat yksikössä (brewery). Railsin nimeämiskäytäntöjen mukaan tästä syntyy
* tietokantataulu nimeltään breweries
* kontrolleri nimeltään BreweriesController (tiedosto breweries_controller.rb)
* model eli yhtä olutpanimoa edustava luokka Brewery (tiedosto Brewery.rb)

Alussa saattaa olla hieman sekavaa milloin ja missä käytetään yksikkö- ja milloin monikkomuotoa, miten tiedostot on nimetty ja mikä niiden sijainti on. Pikkuhiljaa kuitenkin käytänteet juurtuvat selkärankaan ja alkavat vaikuttamaan loogisilta.

Jos sovellus ei ole jo käynnissä, käynnistetään se uudelleen anatamlla komentoriviltä komento <code>rails s</code>. Huom: sovelluksen uudelleenkäynnistys on Railsissa tarpeen melko harvoin. Esim. koodin muuttelu ja lisääminen ei aiheuta uudelleenkäynnistystarvetta.

Railsin konventioiden mukaan kaikkien oluiden lista näkyy osoitteessa breweries, eli mennään sivulle:

    localhost:3000/breweries

Tästä aiheutuu kuitenkin virheilmoitus:

```ruby
Migrations are pending; run 'bin/rake db:migrate RAILS_ENV=development' to resolve this issue.
```

Syynä virheelle on se, että panimot tallettavan tietokantataulun luomisesta huolehtiva tietokantamigraatio on suorittamatta.

Scaffoldin suorittaminen luo hieman erikoisella tavalla nimetyn tiedoston

    db/migrate/20140106173907_create_breweries.rb

Kyseessä on ns. migraatiotiedosto, joka sisältää ohjeen breweries-tietokantataulun luomiseksi. Tietokantataulu saadaan luotua suorittamalla migraatio antamalla komentoriviltä komento <code>rake db:migrate</code>:

```ruby
mbp-18:ratebeer mluukkai$ rake db:migrate
==  CreateBreweries: migrating ================================================
-- create_table(:breweries)
   -> 0.0011s
==  CreateBreweries: migrated (0.0011s) =======================================
```

Panimot tallettava tietokantataulu on nyt luoto ja sovelluksen pitäisi toimia.

Refreshaa panimot näyttävä sivu [http://localhost:3000/breweries](http://localhost:3000/breweries) ja lisää sitä käyttäen tietokantaan nyt kolme panimoa.

Kuten huomaamme, on railsin scaffoldingilla saatu jo melko paljon valmista toiminnallisuutta. Scaffoldingilla luotu toiminnallisuus on hyvä tapa päästä nopeasti alkuun. Mikään silver bullet scaffoldingit eivät kuitenkaan ole, sillä suurin osa scaffoldingeilla valmiiksi luodusta toiminnallisuudesta tullaan ajan myötä korvaamaan itse kirjoitetulla koodilla. Luomme kurssin aikana, viikosta 2 alkaen toiminnallisuutta myös kokonaan käsin, joten myös scaffoldingien automaattisesti generoima koodi tulee tutuksi.

## Konsoli

Rails-sovelluskehittäjän yksi tärkeimmistä työkaluista on Rails-konsoli. Konsoli on interatkiivinen komentotulkki, joka on yhteydessä myös sovelluksen tietokantaan.

Avaa konsoli antamalla komentoriviltä (sovelluksen sisältävästä hakemistosta) komento

    rails console

Jos konsoli antaa virheilmoituksen, johon sisältyy teksti "cannot load such file -- readline (LoadError), niin ainakin Ubuntu 13.10 -ympäristössä tämä korjataan asentamalla libreadline-dev ja kääntämällä ruby uudelleen

    apt-get install libreadline-dev

    rbenv install 2.0.0-p353


Tee kaikki seuraavat komennot myös itse:

```ruby
irb(main):001:0> Brewery.all
  Brewery Load (1.0ms)  SELECT "breweries".* FROM "breweries"
=> #<ActiveRecord::Relation [#<Brewery id: 1, name: "Koff", year: 1897, created_at: "2014-01-06 17:48:10", updated_at: "2014-01-06 17:48:10">, #<Brewery id: 2, name: "Schlenkerla", year: 1687, created_at: "2014-01-06 17:48:22", updated_at: "2014-01-06 17:48:22">, #<Brewery id: 3, name: "Malmgård", year: 2001, created_at: "2014-01-06 17:48:34", updated_at: "2014-01-06 17:48:34">]>
irb(main):002:0> Brewery.count
   (0.2ms)  SELECT COUNT(*) FROM "breweries"
=> 3
irb(main):003:0> Brewery
=> Brewery(id: integer, name: string, year: integer, created_at: datetime, updated_at: datetime)
irb(main):004:0> 
```

Komento <code>Brewery.all</code> siis näyttää kaikki tietokannassa olevat panimot. Konsoli näyttää ensin tietokantaoperaation aiheuttaman SQL-kyselyn ja sen jälkeen kannasta saatavat panimo-oliot. Komento <code>Brewery.count</code> näyttää kannassa olevien panimoiden määrän.

Yhteys breweries-tietokantatauluun siis saadaan luokan <code>Brewery</code> kautta. Railsin scaffold -generaattori loi luokan koodin valmiiksi.

Jos katsotaan miltä luokka (eli tiedosto app/models/brewery.rb) näyttää, huomaamme että se sisältää varsin niukasti koodia:

```ruby
class Brewery < ActiveRecord::Base
end
```

Kuten äskeinen konsolisessio paljasti, on luokalla kuitenkin metodit all ja count, nämä ja todella suuren määrän muita metodeja luokka saa __perimästään__ luokasta <code>ActiveRecord::Base</code>.

Rails-guiden (http://guides.rubyonrails.org/active_record_basics.html) sanoin:

<blockquote>
Active Record is the M in MVC - the model - which is the layer of the system responsible for representing business data and logic. Active Record facilitates the creation and use of business objects whose data requires persistent storage to a database. It is an implementation of the Active Record pattern (https://en.wikipedia.org/wiki/Active_record_pattern) which itself is a description of an Object Relational Mapping system.
</blockquote>

Periaatteena ActiveRecordissa on lyhyesti sanottuna se, että jokaista tietokannan taulua (esim. breweries) vastaa koodissa oma luokka (Brewery). Luokka tarjoaa __luokkametodeina__ metodit, joiden avulla tietokantaa käsitellään. Kun tietokannasta haetaan rivillinen dataa (yhden panimon tiedot), luodaan siitä luokan instanssi (eli Brewery-olio).

ActiveRecordissa luokilla on siis kaksoisrooli, luokkametodien (joita Rubyssä kutsutaan luokan nimen kautta tyyliin <code>Brewery.all</code>) avulla hoidetaan suurin osa tietokantaoperaatioista, esim. tietokantakyselyt. Tietokantaan talletettu data taas mäppäytyy ActiveRecord-luokkien instansseiksi.

Jatketaan konsolista tapahtuvia kokeiluja. Luodaan uusi panimo:

    Brewery.new(name:"Stadin Panimo", year:1997)

Railsissa siis konstruktoria kutsutaan hieman eri tyyliin kuin esim. Javassa. Huomaa, että sulkujen käyttö konstruktori- tai metodikutsussa ei ole välttämätöntä, edellinen oltaisiinkin voitu antaa muodossa

    Brewery.new name:"Stadin Panimo", year:1997

Listaa nyt panimot ja tarkista niiden lukumäärä metodeilla <code>Brewery.all</code> ja <code>Brewery.count</code>. Huomaat, että vaikka loimme uuden olion, ei se mene kuitenkaan tietokantaan!

Olio saadaan talletettua tietokantaan seuraavasti:

    b = Brewery.new name:"Stadin Panimo", year:1997
    b.save

Eli otettiin luotu olio talteen muuttujaan <code>b</code> ja kutsuttiin oliolle metodia <code>save</code>. Huomaa, että muuttujan tyyppiä ei tarvitse (eikä voi) määritellä sillä Ruby on dynaamisesti tyypitetty kieli!
Save on ActiveRecordilta peritty oliometodi, joka kuten arvata saattaa tallettaa olion tietokantaan.

Olion voi myös luoda ja tallettaa suoraan kantaan käyttämällä new:n sijaan luokan metodia create:

   Brewery.create name:"Weihenstephan", year:1042

Kun olio luodaan komennolla <code>new</code>, huomaamme, että olio sisältää kenttiä joiden arvoa ei ole asetettu:

```ruby
irb(main):015:0> b = Brewery.new name:"Stadin Panimo", year:1997
=> #<Brewery id: nil, name: "Stadin Panimo", year: 1997, created_at: nil, updated_at: nil>
```

Kun olio sitten talletetaan, tulee näillekin kentille arvo:

```ruby
irb(main):016:0> b.save
irb(main):017:0> b
=> #<Brewery id: 4, name: "Stadin Panimo", year: 1997, created_at: "2014-01-06 18:25:01", updated_at: "2014-01-06 18:25:01">
```

Kuten arvata saattaa, oliomuuttujat eli olion kentät vastaavat tietokantataulun sarakkeita. Kun olio tallettuu tietokantaan generoi kanta automaattisesti oliolle pääavaimena (engl. primary key) toimivan id:n sekä pari aikaleimaa. Id on siis juuri luodun oluen yksikäsitteinen tunnus.

Katso tilannetta taas [www-sivulta](http://localhost:3000/breweries). Luotujen panimoiden pitäisi nyt olla näkyvissä sivulla.

Metodien <code>new</code> ja <code>create</code> kutsu näytti hieman erikoiselta 

    Brewery.new name:"Stadin Panimo", year:1997

Olemme tässä hyödyntäneet Rubyn vapaamielistä suhtautumista sulkujen käyttöön. Eli sulkujen kanssa kutsu näyttää seuraavalta:

    Brewery.new( name:"Stadin Panimo", year:1997 )

Myös parametri on hieman erikoisessa formaatissa. Kyseessä on symboleilla indeksöity assosiatiivinen taulukko eli hash, ks. https://github.com/mluukkai/WebPalvelinohjelmointi2013/wiki/ruby-intro#hash-ja-symbolit

Kuten yo. linkistä selviää, hashit määritellään aaltosuluissa, tyyliin

    { name:"Stadin Panimo", year:1997 }

Metodikutsun voisi siis kirjoittaa myös muodossa

    Brewery.new( { name:"Stadin Panimo", year:1997 } )

Metodin parametrina olevassa hashissa ei ole kuitankaan pakko käyttää aaltosulkuja kaikissa tapauksissa, joten usein ne jätetäänkin pois. Jos metodilla on useita parametreja, ovat aaltosulkeet joissain tilanteissa tarpeen.

Huom: Rubyssä on myös vaihtoehtoinen syntaksi hashien käyttöön, sitä käyttäen edellinen tulisi muodossa

    Brewery.new :name => "Stadin Panimo", :year => 1997

## ActiveRecordin hakurajapinta

ActiveRecord tarjoaa monipuoliset mahdollisuudet tietokantahakujen tekemiseen ohjelmallisesti eli SQL:ää kirjoittamatta, ks. http://guides.rubyonrails.org/active_record_querying.html

Seuraavassa muutamia esimerkkejä, kokeile kaikkia konsolista:

    Brewery.find 1       # palauttaa olion, jonka id on 1

    b = Brewery.find 2   # palauttaa olion, jonka id on 2 ja tallettaa sen muuttujaan b
    b.year               # muuttujaan b talletetun olion kentän year arvo
    b.name               # muuttujaan b talletetun olion kentän name arvo

    Brewery.find_by name:"Koff"   # palauttaa olion, jonka nimi on Koff

    Brewery.where name:"Koff" # palauttaa taulukon, johon on sijoitettu kaikki Koff-nimiset panimot

    Brewery.where year:1900..2000  # palauttaa taulukon, jossa vuosina 1900-2000 perustetut panimot
   
    b = Brewery.where :name => "Koff"
    b.year                # operaatio ei toimi, sillä where palauttaa taulukon, jossa Koff sijaitsee 

    t = Brewery.where :name => "Koff"
    t.first.year          # t.first sama kuin t[0]

Lisää Rubyn taulukosta ks. https://github.com/mluukkai/WebPalvelinohjelmointi2014/wiki/ruby-intro#taulukko

Huomaa, että jätimme edellä kaikissa esimerkeissä metodikutsuista sulut pois. <code>Brewery.find 1</code> siis tarkoitaa samaa kuin <code>Brewery.find(1)</code>

> ## Tehtävä 4
>
> Lue http://guides.rubyonrails.org/active_record_basics.html#crud-reading-and-writing-data
>
> Tee kaikki seuraavat Rails-konsolista:
> * Luo panimo nimeltä "Kumpulan panimo", jonka perustamisvuosi on 2012 <br />
> * Hae panimo kannasta <code>find_by</code>-metodilla nimen perusteella<br />
> * Muuta panimon perustamisvuodeksi 2014 <br />
> * Hae panimo kannasta uudelleen <code>find_by</code>:lla ja varmista että perustamisvuoden muutos tapahtui <br />
> * Tarkista myös, että panimon kentän <code>updated_at</code> arvo on muuttunut, eli ettei se ole enää sama kuin <code>created at</code> <br />
> * Tuhoa panimo <br />
> * Varmista, että panimo tuhoutui

Vilkaistaan vielä panimon koodia:

```ruby
class Brewery < ActiveRecord::Base
end
```

Pystymme siis koodista käsin pääsemään käsiksi panimo-olioiden kaikkiin kenttiin "pistenotaatiolla" ja voimme asettaa niille vastaavalla tavalla uudet arvot:

    b = Brewery.first         # hakee tietokannasta vanhimman panimon
    b.created_at              # näyttää luontihetken aikaleiman
    b.name = "Sinebrychoff"   # vaihtaa kentän arvoa, huom: muutos menee kantaan vasta olion talletuksen yhteydessä!

Taustalla on hieman Railsin magiaa, sillä Rails luo automaattisesti kaikille olioiden tietokantataulun sarakkeille setteri- ja getterimetodit joiden nimi on täsmälleen sama kuin tietokannan sarake.

Kun sanomme konsolissa <code>b.created_at</code> suoritetaan siis todellisuudessa <code>Brewery</code>:lle automaattisesti lisätty <code>created_at</code>-metodi, joka palauttaa samannimisen kentän arvon. Vastaavasti komento <code>b.name = "Sinebrychoff"</code> aiheuttaa Brewerylle automaattisesti lisätyn kentän <code>name</code> arvoa muuttavan metodin <code>name=</code>-suorittamisen.

## Oluet ja yhden suhde moneen -yhteys

Laajennetaan sovellustamme seuraavaksi oluilla. Jokainen olut liittyy yhteen panimoon, ja panimoon luonnollisesti liittyy useita oluita. Laajennuksen jälkeen sovelluksemme domainin (eli bisneslogiikkaa sisältävien tietokantaan persistoitavien olioiden) luokkamalli näyttää seuraavalta:

![Panimot ja oluet](http://yuml.me/76d4d115)

Luodaan oluita varten malli, kontrolleri ja valmiit näkymät Railsin scaffold-generaattorilla (komento annetaan komentoriviltä):

    rails g scaffold Beer name:string style:string brewery_id:integer

jotta saamme tietokannan päivitettyä, suoritetaan tietokantamigraatio antamalla komentoriviltä komento

    rake db:migrate

Nyt siis on luotu
* oluet tallettava tietokantataulu beers
* tietokantamäppäykseen käytettävä luokka Beer tiedostoon app/models/beer.rb
* oluista huolehtiva kontrolleri BeersController tiedostoon app/controllers/beers_controller.rb
* sekä näkymätiedostoja hakemistoon app/views/beers/

Loimme oluelle string-tyyppiset nimen ja tyylin tallettavat kentät <code>name</code> ja <code>style</code>. Loimme myös integer-tyyppisen kentän <code>brewery_id</code>, jonka tarkoitus on toimia __vierasavaimena__ (engl. foreign key), jonka liittää oluen panimoon.

Tarvittaessa kentät voi tarkistaa kirjoittamalla tietokantataulua vastaavan luokan nimi konsoliin: 

```ruby
irb(main):035:0> Beer
=> Beer(id: integer, name: string, style: string, brewery_id: integer, created_at: datetime, updated_at: datetime)
```

Oluella on siis luonnollisesti myös kaikille ActiveRecord-olioille automaattisesti lisättävät kentät eli id, created_at ja updated_at.

Luodaan konsolista käsin muutama olut ja liitetään ne panimoon vierasavaimen <code>brewery_id</code> avulla (huom: jos konsolisi oli jo auki, saatat joutua antamaan konsolissa komennon <code>reload!</code, joka lataa oluiden ohjelmakoodin konsolin käytettäväksi):

```ruby
irb(main):038:0> koff = Brewery.first
=> #<Brewery id: 1, name: "Koff", year: 1897, created_at: "2014-01-06 17:48:10", updated_at: "2014-01-06 17:48:10">
irb(main):039:0> Beer.create name:"iso 3", style:"Lager", brewery_id:koff.id
=> #<Beer id: 1, name: "iso 3", style: "Lager", brewery_id: 1, created_at: "2014-01-06 20:56:58", updated_at: "2014-01-06 20:56:58">
irb(main):040:0> Beer.create name:"Karhu", style:"Lager", brewery_id:koff.id
=> #<Beer id: 2, name: "Karhu", style: "Lager", brewery_id: 1, created_at: "2014-01-06 20:57:13", updated_at: "2014-01-06 20:57:13">
irb(main):041:0> 
```

Luodut oluet __iso 3__ ja __Karhu__ siis liitetään panimoon Koff. Tietokannan tasolla oluiden ja panimon välillä on liitos. Koodin tasolla liitos ei kuitenkaan vielä toimi.

Jotta saamme liitokset toimimaan myös koodin tasolla, muokataan modeleja seuraavasti:

```ruby
class Beer < ActiveRecord::Base
  belongs_to :brewery
end

class Brewery < ActiveRecord::Base
  has_many :beers
end
```

eli olut liittyy yhteen panimoon ja panimolla on useita oluita. Huomaa monikko ja yksikkö! 
Mennään taas konsoliin. Jos konsoli oli auki kun teit muutokset koodiin, anna ensin komento <code>reload!</code> jotta koodin uusi versio latautuu konsolin käyttöön.

Kokeillaan ensin miten pääsemme käsiksi panimon oluisiin:

```ruby
irb(main):043:0> koff = Brewery.find_by name:"Koff"
=> #<Brewery id: 1, name: "Koff", year: 1897, created_at: "2014-01-06 17:48:10", updated_at: "2014-01-06 17:48:10">
irb(main):044:0> koff.beers.count
=> 2
irb(main):045:0> koff.beers
=> #<ActiveRecord::Associations::CollectionProxy [#<Beer id: 1, name: "iso 3", style: "Lager", brewery_id: 1, created_at: "2014-01-06 20:56:58", updated_at: "2014-01-06 20:56:58">, #<Beer id: 2, name: "Karhu", style: "Lager", brewery_id: 1, created_at: "2014-01-06 20:57:13", updated_at: "2014-01-06 20:57:13">]>
```

<code>Brewery</code>-olioille on siis ilmestynyt metodi <code>beers</code>, joka palauttaa panimoon liittyvät <code>Beer</code>-oliot. Rails generoi automaattisesti tämän metodin nähtyään <code>Brewery</code>-luokassa rivin <code>has_many :beers</code>. Oikeastaan metodi <code>beers</code> ei palauta panimoon liittyviä olioita suoraan, vaan oluiden kokoelmaa edustavan <code>ActiveRecord::Associations::CollectionProxy</code>-tyyppisen olion, jonka kautta oluiden kokoelmaan pääsee käsiksi. Proxy-olio toimii Rubyn kokoelmien kaltaisesti, eli yksittäisiin panimoon liittyviin oluisiin pääsee käsiksi seuraavasti:

```ruby
irb(main):095:0> koff = Brewery.find_by name:"Koff"
irb(main):096:0> koff.beers.first
=> #<Beer id: 1, name: "iso 3", style: "Lager", brewery_id: 1, created_at: "2014-01-06 20:56:58", updated_at: "2014-01-06 20:56:58">
irb(main):097:0> koff.beers.last
=> #<Beer id: 5, name: "Extra Light Triple Brewed", style: "Lager", brewery_id: 1, created_at: "2014-01-06 21:16:49", updated_at: "2014-01-06 21:16:49">
irb(main):098:0> koff.beers[1]
=> #<Beer id: 2, name: "Karhu", style: "Lager", brewery_id: 1, created_at: "2014-01-06 20:57:13", updated_at: "2014-01-06 20:57:13">
irb(main):099:0> koff.beers.to_a
=> [#<Beer id: 1, name: "iso 3", style: "Lager", brewery_id: 1, created_at: "2014-01-06 20:56:58", updated_at: "2014-01-06 20:56:58">, #<Beer id: 2, name: "Karhu", style: "Lager", brewery_id: 1, created_at: "2014-01-06 20:57:13", updated_at: "2014-01-06 20:57:13">, #<Beer id: 3, name: "Lite", style: "Lager", brewery_id: 1, created_at: "2014-01-06 21:12:33", updated_at: "2014-01-06 21:12:33">, #<Beer id: 4, name: "IVB", style: "Lager", brewery_id: 1, created_at: "2014-01-06 21:14:13", updated_at: "2014-01-06 21:14:13">, #<Beer id: 5, name: "Extra Light Triple Brewed", style: "Lager", brewery_id: 1, created_at: "2014-01-06 21:16:49", updated_at: "2014-01-06 21:16:49">]
```

Kokoelmaproxyä voi siis käyttää normaalin taulukon tai kokoelman tyyliin yksittäisiä kokoelman jäseniä aksessoitaessa. Kuten viimeisestä kohdasta huomaamme, proxyyn liittyvät oluet saa taulukkona seuraavasti <code>koff.beers.to_a</code>.

Kokoelmaproxyn alkioiden läpikäynti esim. <code>each</code>-iteraattorilla tapahtuu samoin kuin esim. normaalin taulukon läpikäynti eachilla:

```ruby
irb(main):009:0> koff = Brewery.find_by name:"Koff"
irb(main):010:0> koff.beers.each{ |b| puts b.name }
Iso 3
Karhu
Tuplahumala
```

Myös olueeseen liittyvään panimoon pääsee käsiksi helposti kooditasolla:

```ruby
irb(main):046:0> bisse = Beer.first
=> #<Beer id: 1, name: "iso 3", style: "Lager", brewery_id: 1, created_at: "2014-01-06 20:56:58", updated_at: "2014-01-06 20:56:58">
irb(main):047:0> bisse.brewery
=> #<Brewery id: 1, name: "Koff", year: 1897, created_at: "2014-01-06 17:48:10", updated_at: "2014-01-06 17:48:10">
1.9.3-p385 :020 > 
```

Eli <code>Beer</code>-luokkaan lisätty rivi <code>belongs_to :brewery</code> lisää oluille metodin <code>brewery</code>, joka palauttaa olueseen tietokannassa liitetyn panimo-olion.

## Tietokannan alustus 

Ohjelmiston kehitysvaiheessa saattaa joskus olla hyödyksi generoida tietokantaan "kovakoodattua" dataa. 
Oikea paikka tälläiselle datalle on tiedosto db/seeds.rb

Kopioi seuraava sisältö sovelluksesi seeds.rb-tiedostoon:

```ruby
b1 = Brewery.create name:"Koff", year:1897
b2 = Brewery.create name:"Malmgard", year:2001
b3 = Brewery.create name:"Weihenstephaner", year:1042

b1.beers.create name:"Iso 3", style:"Lager"
b1.beers.create name:"Karhu", style:"Lager"
b1.beers.create name:"Tuplahumala", style:"Lager"
b2.beers.create name:"Huvila Pale Ale", style:"Pale Ale"
b2.beers.create name:"X Porter", style:"Porter"
b3.beers.create name:"Hefezeizen", style:"Weizen"
b3.beers.create name:"Helles", style:"Lager"
```

Tiedoston sisältö on siis normaalia Rails-koodia. Saat suoritettua tiedoston komennolla

    rake db:seed

Poistetaan ensin kaikki vanha data tietokannasta antamalla komentoriviltä komento:

    rake db:reset

Komento "seedaa" kannan automaattisesti eli vanhan datan poistamisen lisäksi suorittaa myös tiedoston seeds.rb sisällön.

Tutkitaan uutta dataa konsolista käsin:

```ruby
irb(main):048:0> koff = Brewery.find_by name:"Koff"
=> #<Brewery id: 1, name: "Koff", year: 1897, created_at: "2014-01-06 17:48:10", updated_at: "2014-01-06 17:48:10">
irb(main):049:0> koff.beers
=> #<ActiveRecord::Associations::CollectionProxy [#<Beer id: 1, name: "iso 3", style: "Lager", brewery_id: 1, created_at: "2014-01-06 20:56:58", updated_at: "2014-01-06 20:56:58">, #<Beer id: 2, name: "Karhu", style: "Lager", brewery_id: 1, created_at: "2014-01-06 20:57:13", updated_at: "2014-01-06 20:57:13">]>
irb(main):050:0> 
```

Luodaan uusi olut-olio. Käytetään tällä kertaa new-metodia, jolloin olio ei vielä talletu tietokantaan:

```ruby
irb(main):050:0> b = Beer.new name:"Lite", style:"Lager"
=> #<Beer id: nil, name: "Lite", style: "Lager", brewery_id: nil, created_at: nil, updated_at: nil>
```

Olut ei ole tietokannassa, eikä myöskään liity vielä mihinkään panimoon:

```ruby
irb(main):051:0> b.brewery
=> nil
```

Oluen voi liittää panimoon muutamallakin tavalla. Voimme asettaa oluen panimokentän arvon käsin:

```ruby
irb(main):052:0> b.brewery = koff
=> #<Brewery id: 1, name: "Koff", year: 1897, created_at: "2014-01-06 17:48:10", updated_at: "2014-01-06 17:48:10">
irb(main):053:0> b
=> #<Beer id: nil, name: "Lite", style: "Lager", brewery_id: 1, created_at: nil, updated_at: nil>
```

Kuten huomaamme, tulee oluen brewery_id-vierasavaimeksi panimon id. Olut ei ole vielä tietokannassa, eikä panimokaan vielä tästä syystä tiedä, että luotu olut liittyy siihen:

```ruby
irb(main):054:0> koff.reload
irb(main):055:0> koff.beers.include? b
=> false
```

Huom: kutsuimme ensin varalta panimon tietokannasta uudelleenlataavaa metodia <code>reload</code>, muuten olion tila ei olisi ollut tuore, ja siihen liittyvä olutlistakin olisi vastannut olion lataushetken oluiden listaa.

Olut saadaan tallettumaan tuttuun tapaan komennolla <code>save</code>. Tämän jälkeen myös panimon mielestä olut liittyy panimoon (jälleen lataamme olion ensin kannasta uudelleen):

```ruby
irb(main):056:0> b.save
irb(main):057:0> koff.reload
irb(main):058:0> koff.beers.include? b
=> true
```

Hieman kätevämpi tapa on liittää olut panimon oluiden joukkoon << operaattorilla:

```ruby
irb(main):061:0> b = Beer.new name:"IVB", style:"Lager"
=> #<Beer id: nil, name: "IVB", style: "Lager", brewery_id: nil, created_at: nil, updated_at: nil>
irb(main):062:0> koff.beers << b
```

Vaikka luotua olutta ei tässä eksplisiittisesti talletettu <code>save</code>-metodilla, tallentuu olut kantaan operaattorin << käytön ansiosta.

Kolmas tapa on tiedostossa <code>seeds.rb</code> käytetty tyyli, jossa metodia <code>create</code> kutsutaan suoraan panimon beers-kokoelmalle:

```ruby
irb(main):063:0> koff.beers.create name:"Extra Light Triple Brewed", style:"Lager"
```

> ## Tehtävä 5: Panimoja ja oluita
>
>
> Tee konsolista käsin seuraavat toimenpiteet:
> * Luo panimo Hartwall ja sille kolme olutta kaikkia kolmea yllä demonstroitua tapaa käyttäen.
> * Päädymme kuitenkin siihen että Hartwall on huonon laatunsa takia poistettava. Ennen poistamista, ota muistiin Hartwall-olion id
> * Hartwallin poistaminen jättää tietokantaan olut-olioita, jotka liittyvät jo poistettuun panimoon
> * Hae orvoksi jääneet oluet komennolla <code>Beer.where tähänsopivaparametri</code>
> * Tuhoa operaation palauttamat oluet. Ohjeita oluiden listan läpikäyntiin esim. seuraavasta https://github.com/mluukkai/WebPalvelinohjelmointi2013/wiki/ruby-intro#taulukko

## Kontrollerin ja viewien yhteys

Tutkitaan hieman panimon valmiiksi generoitua kontrolleria app/controller/breweries_controller.rb
 
Kontrolleri on siis nimetty Railsin konvention mukaan monikkomuodossa. Kontrollerissa on Railsin konventioiden mukaan 6 metodia, tutkitaan niistä aluksi kaikkien oluiden näyttämisestä huolehtivaa metodia <code>index</code>: 

```ruby
class BreweriesController < ApplicationController
  def index
    @breweries = Brewery.all
  end
end
```

Metodi sisältää ainoastaan komennon

    @breweries = Brewery.all

eli sijoittaa kaikkien panimoiden listan <code>@breweries</code>-nimiseen muuttujaan, jonka avulla se välittää panimoiden listan näkymälle. Tämän jälkeen metodi index renderöi näkymätemplatessa app/views/breweries/index.html.erb määritellyn html-sivun. Metodi ei missään vaiheessa viittaa näkymätemplateen tai sisällä käskyä sen renderöintiin. Kyse on jälleen Railsin convention over configuration -periaatteesta, eli jos ei muuta sanota, renderöidään kontrollerin index-metodin lopussa index.html.erb-näkymätemplate. 

Renderöintikomento voitaisiin kirjoittaa myös eksplisiittisesti:

```ruby
  def index
    @breweries = Brewery.all
    render :index   # renderöi hakemistossa view/breweries olevan näkymätemplaten index.html.erb
  end
```

Näkymätemplatet, eli erb-tiedostot ovat html:ää, joihin on upotettu Ruby-koodia. 

Tarkastellaan valmiiksigeneroitua näkymätemplatea eli tiedostoa app/views/breweries/index.html.erb

```
<h1>Listing breweries</h1>

<table>
  <thead>
    <tr>
      <th>Name</th>
      <th>Year</th>
      <th></th>
      <th></th>
      <th></th>
    </tr>
  </thead>

  <tbody>
    <% @breweries.each do |brewery| %>
      <tr>
        <td><%= brewery.name %></td>
        <td><%= brewery.year %></td>
        <td><%= link_to 'Show', brewery %></td>
        <td><%= link_to 'Edit', edit_brewery_path(brewery) %></td>
        <td><%= link_to 'Destroy', brewery, method: :delete, data: { confirm: 'Are you sure?' } %></td>
      </tr>
    <% end %>
  </tbody>
</table>

<br>

<%= link_to 'New Brewery', new_brewery_path %>
```

Näkymätemplate muodostaa taulukon, jossa jokainen muuttujan @breweries sisältämä panimo tulee omalle rivilleen. 

Näkymätemplateen upotettu Ruby-koodi tulee <% %> merkkien sisälle. <%= %> taas aiheuttaa Ruby-komennon arvon tulostumisen ruudulle.

Tutustumme taulukon generointiin kohta hieman tarkemmin. Lisätään ensin sivulle (eli erb-templateen) tieto panimoiden yhteenlasketusta määrästä. Eli lisää johonkin kohtaan sivua, esim. heti h1-tagien sisällä olevan otsikon jälkeen seuraava rivi

```
<p> Number of breweries: <%= @breweries.count %> </p> 
```

Mene nyt selaimella [panimot listaavalle sivulle](http://localhost:3000/breweries) ja varmista, että lisäys toimii.

Palataan sitten tarkemmin HTML-taulukon muodostavaan koodiin. Jokainen panimo tulostuu omalle rivilleen taulukkoon Rubyn <code>each</code>-iteraattoria käyttäen:

```
    <% @breweries.each do |brewery| %>
      <tr>
        <td><%= brewery.name %></td>
        <td><%= brewery.year %></td>
        <td><%= link_to 'Show', brewery %></td>
        <td><%= link_to 'Edit', edit_brewery_path(brewery) %></td>
        <td><%= link_to 'Destroy', brewery, method: :delete, data: { confirm: 'Are you sure?' } %></td>
      </tr>
    <% end %>
```

Muuttujaan ```@breweries``` talletettu panimoiden lista käydään läpi ```each```-iteraattorin avulla. (lisää eachista ks. https://github.com/mluukkai/WebPalvelinohjelmointi2013/wiki/ruby-intro#each). Jokaista yksittäistä panimoa (joihin viitataan iteraattorin toistettavassa koodilohkossa nimellä <code>brewery</code>) kohti luodaan taulukkoon tr-tagien sisällä oleva rivi, jossa on viisi saraketta. Ensimmäiseen sarakkeeseen tulee panimon nimi ```<%= brewery.name %>``` ja toiseen perustamisvuosi. Kolmanteen sarakkeeseen generoituu linkki panimon tiedot näyttävälle sivulle. Linkin generoiva Ruby-koodi on ```<%= link_to 'Show', brewery %>``` .

Kyseessä on oikeastaan lyhennysmerkintä seuraavasta:

```
<%= link_to 'Show', brewery_path(brewery.id) %> 
```
joka generoi sivulle seuraavanlaisen HTML-koodin (seuraavassa oleva numero riippuu taulukon rivillä olevan olion id-kentän arvosta):

```
<a href="/breweries/3">Show</a>
```

eli linkin osoitteeseen "breweries/3". Komennon ```link_to``` ensimmäinen parametri siis on a-tagiin tuleva nimi, ja toinen on linkin osoite. 

Itse osoite luodaan tässä pitemmässä muodossa apumetodilla ```brewery_path(brewery.id)``` joka palauttaa polun id:n ```brewery.id``` omaavan panimon sivulle. Saman asian siis metodin <code>link_to</code> parametrina saa aikaan olio itse, eli esimerkkimme tapauksessa muuttuja <code>brewery</code>

Linkin generoivan komennon voisi myös "kovakoodata" muodossa ```<%= link_to 'Show', "breweries/#{brewery.id}" %>```, mutta kovakoodaus ei ole yleensä eikä tässäkään tapauksessa kovin järkevää.

Mitä tarkoittaa ```"breweries/#{brewery.id}"```? Ks. https://github.com/mluukkai/WebPalvelinohjelmointi2013/wiki/ruby-intro#merkkijonot

> ## Tehtävä 6 
> muuta panimon nimi klikattavaksi ja poista taulukosta show-kenttä linkkeineen

Tehtävän jälkeen sovelluksesi panimot näyttävien sivujen tulisi näyttää seuraavalta

![kuva](http://www.cs.helsinki.fi/u/mluukkai/wadror/brewery-w1-0.png)

## Oluiden listaaminen panimon sivulla

Tutkitaan yksittäisen panimon näyttämistä. Url panimon sivulle on muotoa "breweries/3", missä numero on panimon id. Panimon sivulle menemisestä huolehtii breweries-kontrollerin metodi show:

```ruby
class BreweriesController < ApplicationController
  before_action :set_brewery, only: [:show, :edit, :update, :destroy]

  # muita metodeja...

  def show
  end

end
```

Metodi ei sisällä mitään koodia! Huomaamme kuitenkin, että luokan määrittelyn alussa on rivi 

    before_action :set_brewery, only: [:show, :edit, :update, :destroy]

Tämä taas saa aikaan sen, että ennen jokaista lueteltua metodia (show, edit, update ja destroy) suoritetaan metodin <code>set_brewery</code> koodi. Metodin määrittely löytyy luokan loppupuolelta:

```ruby
class BreweriesController < ApplicationController
  before_action :set_brewery, only: [:show, :edit, :update, :destroy]

  # ...

  def show
  end

  # ...
 
  private
    def set_brewery
      @brewery = Brewery.find(params[:id])
    end

end
```

Ennen metodin <code>show</code> suoritusta siis suoritetaan komento

    @brewery = Brewery.find(params[:id])

joka viittaa muuttujaan ```params```, joka taas sisältää suorituksen alla olevaan HTTP-kutsuun liittyvät tiedot. Muuttuja <code>params</code> on tyypiltään assosiatiivinen taulukko eli hash. Erityisesti muttujan arvo avaimella <code>:id</code> eli ```params[:id]``` kertoo tässä tapauksessa tarkasteltavana olevan panimon id:n, eli sivun polun breweries/xx, kenoviivan jälkeisen osan. 

Panimo haetaan tietokannasta tutulla komennolla ```Brewery.find``` ja sijoitetaan muuttujaan ```@brewery```.
Metodi <code>show</code> renderöi lopuksi näkymätemplaten ```show.html.erb```. Näkymätemplaten generointi tapahtuu jälleen automaattisesti Railsin konvention perusteella, eli panimokontrollerin metodin ```show``` suorituksen lopussa renderöidään näkymä views/breweries/show.html.erb ellei koodi määrää muuta.

Eksplisiittisesti auki kirjoitettuna metodin <code>show</code> suorituksen yhteydessä suoritettava koodi on siis seuraava:

```ruby
    @brewery = Brewery.find(params[:id])
    render :show
```

Näkymätemplaten views/breweries/show.html.erb koodi on seuraavassa:

```
<p id="notice"><%= notice %></p>

<p>
  <strong>Name:</strong>
  <%= @brewery.name %>
</p>

<p>
  <strong>Year:</strong>
  <%= @brewery.year %>
</p>

<%= link_to 'Edit', edit_brewery_path(@brewery) %> |
<%= link_to 'Back', breweries_path %>
```

Sivun yläosassa oleva id:llä __notice__ varustettu osa on tarkoitettu näyttämään panimon luomiseen tai muutokseen liittyviä viestejä, asiasta lisää myöhemmin.

> ## Tehtävä 7: Panimon sivun hiominen
> 
>
> Lisätään sivulle tieto panimoon liittyvien oluiden määrästä eli renderöi sivun sisällä <code>@brewery.beers.count</code>
>
>
> Muokkaa valmista sivua siten, että panimon nimestä tulee h2-tason otsikko ja vuosi ilmoitetaan kursivoituna tyyliin "_Established_ _at_ _1897_".

Jatketaan muutosten tekemistä.

> ## Tehtävä 8: Oluet panimon sivulle
> 
> Lisätään nyt panimon sivulle lista panimoon liittyvistä oluista. Lisää aluksi sivulle seuraava <code><%= @brewery.beers.to_a %></code> ja katso aikaansannosta. 
> 
> Listaa seuraavaksi ainoastaan oluiden nimet käyttäen each-toistoa:
> 
> ```ruby
> <p>
>  <% @brewery.beers.each do |beer| %>
>    <%= beer.name %>
>  <% end %>
> </p>
> ```
> Muuta vielä oluiden nimet klikattavaksi metodin <code>link_to</code> avulla

Sivusi tulisi näyttää tehtävän jälkeen seuraavalta

![panimo ja oluet](http://www.cs.helsinki.fi/u/mluukkai/wadror/brewery-w1-1.png)

Parannellaan vielä hieman sovelluksemme navigaatiota.

> ## Tehtävä 9
>
> Lisää kaikkien panimojen sivulle linkki oluiden sivulle ja vastaavasti oluiden sivulle linkki panimoiden sivulle, esim. linkki oluiden sivulle saadaan komennolla ```link_to 'list of beers', beers_path```

Viritellään lopuksi kaikkien oluiden listaa.

> ## Tehtävä 10
> 
> Tällä hetkellä kaikkien oluiden listalla näytetään olueeseen liittyvän panimon id
>
> Muuta sivua siten että panimon id:n sijaan näytetään olueeseen liittyvän panimon nimi, ja että nimeä klikkaamalla päästään panimon sivulle
>
> Muuta myös oluen nimi klikattavaksi ja poista show-sarake
>
> Huom: jos törmäät ongelmiin, kannattaa lukea seuraava luku!

Lopputuloksen pitäisi näyttää seuraavalta:

![kuva](https://github.com/mluukkai/WebPalvelinohjelmointi2014/raw/master/images/brewery-w1-3.png)

## nil

Saatat törmätä seuraavanlaiseen virheilmoitukseen

![kuva](https://github.com/mluukkai/WebPalvelinohjelmointi2014/raw/master/images/brewery-w1-2.png)

Kyse on oikeastaan klassisesta nullpointer-poikkeuksesta, tai sen Ruby-versiosta nilpointer-poikkeuksesta. Rails vihjaa, että olet yrittänyt kutsua nil:ille (joka on Rubyssä olio!) metodia name, ja että sellaista ei ole. Syynä tälle on todennäköisesti se, että tietokannassasi on oluita joihin ei liity panimoa tai että niihin liittyvä panimo on poistettu. 

Voit poistaa ongelman aiheuttavat oluet käsin tai konsolin avulla. Saat haettua orvot oluet konsolista komennolla: 

    orvot_oluet = Beer.all.select{ |b| b.brewery.nil? }

ja niiden poistaminen onnistuu sitten each-iteraattorin avulla

    orvot_oluet.each{ |o| o.delete }

## Kertausta: polkujen ja kontrollerien nimentäkonventiot 
 
Loimme siis sovellukseemme tietokantataulut panimoille ja oluille sekä molempien hallinnointiin tarkoitetut kontrollerit ja näkymät. Kerrataan vielä Railsin nimentäkonventioita, joihin tottumiseen saattaa aloittelijalla mennä hetki.

Panimo ja siihen liittyvät kontrollerit ja näkymät luotiin Railsin scaffold-generaattorilla seuraavasti:

    rails g scaffold Brewery name:string year:integer

Tästä seurauksena syntyi 
* tietokantataulu <code>breweries</code>
* kontrolleri <code>BreweriesController</code> hakemistoon app/controllers/
* model <code>Brewery</code> hakemistoon app/models/
* joukko näkymiä hakemistoon app/views/breweries
* tietokannan muodostamisesta huolehtiva migraatiotiedosto hakemistoon /db/migrate

Railsin konvention mukaan kaikkien panimoiden sivun URL on breweries, yksittäisten panimoiden sivujen URLit taas ovat muotoa breweries/3, missä numerona on panimon id.

URLeja ei itse kannata kirjoittaa näkymätemplateihin sillä Rails tarjoaa path_helper-metodeja (ks. http://guides.rubyonrails.org/routing.html#path-and-url-helpers), joiden avulla URLit saa generoitua.

Kaikkien panimoiden URLin (tai oikeastaan vain URLin jälkiosan) generoi metodi <code>breweries_path</code>, yksittäisen panimon URL saadaan generoitua metodilla <code>brewery_path(id)</code>, missä parametrina on linkin kohteena olevan panimon id.

Helppereitä käytetään usein yhdessä apumetodin <code>link_to</code>code> kanssa. link_to generoi HTML-sivulle linkin eli a-tagin. 

Linkin panimon <code>brewery</code> sivulle voi generoida seuraavasti:

```ruby
    <%= link_to "linkki panimoon #{brewery.name}", brewery_path(brewery.id) %>
```

Ensimmäisenä parametrina on siis linkin teksti ja toisena kohteena oleva osoite.

Usein tehtäessä linkkiä yksittäisen olion sivulle käytetään edellisestä lyhempää muotoa:

```ruby
    <%= link_to "linkki panimoon #{brewery.name}", brewery %>
```

Nyt toisena parametrina on siis suoraan olio, jonka sivulle linkki johtaa. Kun toinen parametri on olio, korvaa Rails sen automaattisesti todellisen polun generoimalla koodilla <code>brewery_path(brewery.id)</code>code>

Railsin automaattisesti generoiduissa kontrollereissa on valmiina kuusi metodia. Kaikkien panimoiden listaa, eli osoitetta /breweries hallinnoi metodi <code>index</code>, yksittäisen panimon osoitetta, esim. /breweries/3 hallinnoi kontrollerin metodi <code>show</code>. Tutustumme myöhemmin kontrollerin muihin metodeihin.

Kontrollerien metodit renderöivät lopuksi käyttäjälle palautettavan HTML-sivun muodostavan templaten. Oletusarvoisesti panimokontrollerin metodi <code>index</code> renderöi näkymätemplaten app/views/breweries/index.html.erb ja metodi <code>show</code> renderöi näkymätemplaten app/views/breweries/show.html.erb 

Kontrollereiden ei siis tarvitse erikseen kutsua renderöintiä suorittavaa metodia <code>render</code> jos ne renderöivät oletustemplaten. Eli koodi

```ruby
class BreweriesController < ApplicationController
  def index
    @breweries = Brewery.all
    render :index
  end
```

toimii täsmälleen samalla tavalla kuin seuraava

```ruby
class BreweriesController < ApplicationController
  def index
    @breweries = Brewery.all
  end
```

Eksplisiittinen <code>render</code>-metodin kutsuminen on siis tarpeen vain silloin kun kontrolleri renderöi jonkin muun kuin oletusnäkymän.

> ## Tehtävä 11 
>
> Muuta tilapäisesti panimokontrollerin <code>index</code>-metodia seuraavasti
>
> ```ruby
>  def index
>    @breweries = Brewery.all
>
>    render :panimot
>  end
> ```
>
> Kokeile mitä tapahtuu kun menet panimoiden sivulle eli osoitteeseen http://localhost:3000/breweries
>
> Lisää nyt hakemistoon app/views/breweries tiedosto panimot.html.erb ja lisää sinne esim. 
>     panimoita <%= @breweries.count %>
>
> Mene panimoiden sivulle.
>
> Palauta metodi nyt entiselleen.

## Sovellus internettiin

Tällä hetkellä käytännöllisin tapa sovellusten hostaamiseen on PaaS (eli Platform as a Service) -palvelu [Heroku](http://heroku.com). Heroku tarjoaa web-sovellukselle tietokannan ja suoritusympäristön. Vähän kapasiteettia käyttäville sovelluksille Heroku on ilmainen. 

Sovelluksen deployaaminen Herokuun onnistuu helpoiten jos sovelluksen hakemisto on oma git-repositorionsa. 

Luo Herokuun tunnus.

Luo ssh-avain ja lisää se herokuun sivulla https://dashboard.heroku.com/account
* ohje ssh-avaimen luomiseen http://www.cs.helsinki.fi/group/kuje/compfac/ssh_avain.html

Asenna herokun komentoriviliittymän sisältävä Heroku Toolbelt sivun https://toolbelt.heroku.com/ ohjeiden mukaan.

**Huom:** Heroku Toolbeltin asentaminen vaatii admin-oikeuksia ja näinollen asennus laitoksen koneille ei onnistu. Saat kuitenkin asennettua Herokun komentorivikäyttöliittymän laitoksen koneille seuraavasti:
* pura sivulta https://github.com/heroku/heroku löytyvä Tarball sopivaan paikkaan kotihakemistosi alle
* lisää purettu hakemisto PATH:iin eli suorituspolulle, eli lisäämällä kotihakemistossasi olevaan <code>.bash_profile</code> tiedostoon rivi <code>export PATH=$PATH:~/heroku-client</code> (olettaen että purit Tarballin kotihakemistoon)


Mene sitten sovelluksen juurihakemistoon, ja luo sovellusta varten heroku-instanssi:

```ruby
mbp-18:viikko1 mluukkai$ heroku create
Creating infinite-thicket-5011... done, stack is cedar
http://infinite-thicket-5011.herokuapp.com/ | git@heroku.com:infinite-thicket-5011.git
Git remote heroku added
mbp-18:viikko1 mluukkai$ 
```

Sovelluksen URL tulee olemaan tässä tapauksessa http://infinite-thicket-5011.herokuapp.com/. Sovelluksen URLin alkuosan saa haluamaansa muotoon antamalla komennon muodossa **heroku create urlin_alkuosa**

Railsissa sovellukset käyttävät oletusarvoisesti sqlite-tietokantaa, mutta Herokussa käytössä on PostgreSQL-tietokanta. Rails-sovelluksen käyttämät kirjastot eli Rubyn termein gemit on määritelty sovelluksen juuressa olevassa Gemfile-nimisessä tiedostossa. Jotta saamme PostgreSQLn käyttöön, joudumme tekemään muutoksen Gemfileen.

Poista rivi

```ruby
gem 'sqlite3'
```

ja lisää johonkin kohtaa tiedostoa seuraavat

```ruby
group :development, :test do
  gem 'sqlite3'
end

group :production do
   gem 'pg'
   gem 'rails_12factor' 
end
```

Suoritetaan komentoriviltä komento <code>bundle install</code>, jotta muutokset tulevat käyttöön:

```ruby
mbp-18:viikko1 mluukkai$ bundle install
Fetching gem metadata from https://rubygems.org/..........
Fetching additional metadata from https://rubygems.org/..
Resolving dependencies...
Using rake (10.1.1)
Using i18n (0.6.9)
...
Using uglifier (2.4.0)
Your bundle is complete!
Use `bundle show [gemname]` to see where a bundled gem is installed.
```

Committoidaan kaikki muutokset versionhallintaan. 

```ruby
mbp-18:viikko1 mluukkai$ git add -A
mbp-18:viikko1 mluukkai$ git commit -m"updated Gemfile for Heroku"
[master 590265a] updated Gemfile for Heroku
 2 files changed, 16 insertions(+), 2 deletions(-)
```

Nyt olemme valmiina käynnistämään sovelluksen herokussa. Sovellus käynnistetään suorittamalla komentoriviltä operaatio <code>git push</code>

```ruby
mbp-18:viikko1 mluukkai$ git push heroku master
Initializing repository, done.
Counting objects: 107, done.
Delta compression using up to 4 threads.
Compressing objects: 100% (98/98), done.
Writing objects: 100% (107/107), 21.72 KiB | 0 bytes/s, done.
Total 107 (delta 13), reused 0 (delta 0)

-----> Ruby app detected
-----> Compiling Ruby/Rails
-----> Using Ruby version: ruby-2.0.0
-----> Installing dependencies using Bundler version 1.3.2
       New app detected loading default bundler cache
       Running: bundle install --without development:test --path vendor/bundle --binstubs vendor/bundle/bin --deployment
       Fetching gem metadata from https://rubygems.org/..........
       Fetching gem metadata from https://rubygems.org/..
       Installing rake (10.1.1)
       Installing i18n (0.6.9)
       Using minitest (4.7.5)
       Using multi_json (1.8.2)
 	   ...
       Removing sprockets (2.2.2)
       Removing rails_serve_static_assets (0.0.1)
-----> Writing config/database.yml to read from DATABASE_URL
-----> Preparing app for Rails asset pipeline
       Running: rake assets:precompile
       I, [2014-01-07T19:40:29.177021 #1247]  INFO -- : Writing /tmp/build_f5086fb0-21d2-4e48-b7b4-1e968532e2ca/public/assets/application-7bc90441581a986f868a4ad89f3dcaed.js
       I, [2014-01-07T19:40:29.230189 #1247]  INFO -- : Writing /tmp/build_f5086fb0-21d2-4e48-b7b4-1e968532e2ca/public/assets/application-27fc57308d4ce798da2b90e9a09dad4f.css
       Asset precompilation completed (7.84s)
       Cleaning assets
-----> WARNINGS:
       You have not declared a Ruby version in your Gemfile.
       To set your Ruby version add this line to your Gemfile:
       ruby '2.0.0'
       # See https://devcenter.heroku.com/articles/ruby-versions for more information.
-----> Discovering process types
       Procfile declares types -> (none)
       Default types for Ruby  -> console, rake, web, worker

-----> Compressing... done, 21.3MB
-----> Launching... done, v5
       http://infinite-thicket-5011.herokuapp.com deployed to Heroku

To git@heroku.com:infinite-thicket-5011.git
 * [new branch]      master -> master
mbp-18:viikko1 mluukkai$ 
```

Sovelluksen käynnistys näytti onnistuneen ongelmitta. 

Avataan nyt selaimella panimoiden listan näyttävä sivu http://infinite-thicket-5011.herokuapp.com/breweries

Seurauksena on kuitenkin ikävä virheilmoitus "We're sorry, but something went wrong.".

Voimme koittaa selvittää vikaa katsomalla herokun lokeja komennolla <code>heroku logs</code>. Tulostusta tulee aika paljon, mutta pienen etsinnän jälkeen syy selviää:

<pre>
2014-01-07T19:43:53.105207+00:00 app[web.1]: Started GET "/breweries" for 84.253.203.234 at 2014-01-07 19:43:53 +0000
2014-01-07T19:43:53.107853+00:00 app[web.1]: Processing by BreweriesController#index as HTML
2014-01-07T19:43:53.144805+00:00 heroku[router]: at=info method=GET path=/breweries host=infinite-thicket-5011.herokuapp.com fwd="84.253.203.234" dyno=web.1 connect=4ms service=46ms status=500 bytes=1266
2014-01-07T19:43:53.136627+00:00 app[web.1]: PG::UndefinedTable: ERROR:  relation "breweries" does not exist
2014-01-07T19:43:53.136627+00:00 app[web.1]: LINE 5:                WHERE a.attrelid = '"breweries"'::regclass
2014-01-07T19:43:53.136627+00:00 app[web.1]:                                           ^
</pre>

Syynä on siis se, että tietokantaa ei ole luotu. Meidän on siis suoritettava migraatiot Herokussa olevalle sovellukselle. Tämä onnistuu komennolla <code>heroku run rake db:migrate</code>

Ja nyt sovellus toimii!

Jatkossakin on siis aina muistettava suorittaa migraatiot deployatessamme sovellusta Herokuun.

Voimme myös avata Rails-konsolin Herokussa sijaitsevalle sovellukselle komennolla

```ruby
mbp-18:viikko1 mluukkai$ heroku run console
Running `console` attached to terminal... up, run.3403
Loading production environment (Rails 4.0.2))
irb(main):001:0> Brewery.all
=> #<ActiveRecord::Relation [#<Brewery id: 1, name: "Koff", year: 1897, created_at: "2014-01-07 20:03:16", updated_at: "2014-01-07 20:03:16">]>
irb(main):004:0> 
```

Kyseessä on normaali Rails-konsolisessio, eli voit esim. tutkia Herokuun deployatun sovelluksen tietokannan tilaa session avulla.    

## Riippuvuuksien hallinta ja suoritusympäristöt

Kuten edellisessä luvussa mainittiin Rails-sovelluksen käyttämät kirjastot eli gemit on määritelty sovelluksen juuressa olevassa Gemfile-nimisessä tiedostossa. 

Ennen edellisessä luvussa tekemiämme muutoksia Gemfile näyttää seuraavalta (poiskommentoidut osat on jätetty allaolevasta pois):

```ruby
source 'https://rubygems.org'

gem 'rails', '4.0.2'
gem 'sqlite3'
gem 'sass-rails', '~> 4.0.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'jquery-rails'
gem 'turbolinks'
gem 'jbuilder', '~> 1.2'
```

Gemfile siis listaa joukon gemejä joita sovellus käyttää. Kuten huomaamme, on Rails itsekin gem. Joissain tapauksissa gemin yhteydessä määritellään käytettävä versio tai minimissään käyvä versionumero.

Riippuvuudet ladataan osoitteesta https://rubygems.org Bundler-ohjelmaa, ks. http://bundler.io/ käyttäen antamalla komentoriviltä komento <code>bundle install</code>. Bundler lataa gemit ja niiden riippuvuudet rubygems.org:ista ja tämän jälkeen sovellus on valmiina käytettäväksi. 

Kun <code>bundle install</code> on suoritettu ensimmäisen kerran, syntyy tiedosto <code>Gemfile.lock</code> joka määrittelee tarkasti mitkä versiot gemeistä on asennettu. Gemfilehän ei määrittele välttämättä tarkkoja versioita. Tämän jälkeen kutsuttaessa <code>bundle install</code> asennetaan Gemfile.lock tiedostossa määritellyt versiot. Suorittamalla <code>bundle update</code> saadaan tarvittaessa ladattua uusimmat gemit ja luodaan uusi Gemfile.lock-tiedosto. Katso tarkemmin Bundlerin toiminnasta ositteesta http://bundler.io/v1.5/rationale.html

Rails tarjoaa oletusarvoisesti kolme eri suoritusympäristöä
* development eli sovelluskehitykseen tarkoitettu ympäristö
* test eli testien suorittamiseen tarkoitettu ympäristö
* production eli tuotantokäyttöön tarkoitettu ympäristö

Jokaisessa suoritusympäristössä on käytössä oma tietokanta ja Rails toimii myös hieman eri tavalla eri ympäristöissä.

Normaalisti ohjelmoija työskentelee siten että sovellusta suoritetaan development-ympäristössä. Tällöin Rails tarjoaa mm. sovelluskehittäjän työtä helpottavia virheilmoituksia. Myös sovelluksen koodi ladataan aina suoritettaessa uudelleen. Tämän ansiosta sovellusta ei tarvitse käynnistää uudelleen koodia muutettaessa vaan muutettu ja lisätty koodi on aina "automaattisesti" sovelluksen käytössä.

Herokuun deployattaessa sovellus alkaa toimia production-ympäristössä joka sisältää useita suorituskykyä optimoivia eroja development-ympäristöön nähden. Myös sovelluksen virheilmoitukset ovat erilaiset, virheen syyn ja sijainnin sijaan ilmoitetaan ainoastaan "Something went wrong...".

Testausympäristöön tutustumme kurssin viikolla 4.

Joskus eri ympäristöt tarvitsevat erilaisia riippuvuuksia, esim. kun sovellusta suoritetaan Herokussa production-ympäristössä on käytössä PostgreSQL-tietokanta, kun taas sovelluskehityksessä käytetään kevyempää sqlite3-tietokantaa. Samat gemit eivät siis sovellu kaikkiin suoritusympäristöihin.

Eri ympäristöjen käyttäminen gemit voidaan määritellä Gemfilessä group-lohkojen avulla. Seuraavassa sovelluksemme Gemfile Herokun edellyttämien muutosten jälkeen:

```ruby
source 'https://rubygems.org'

gem 'rails', '4.0.2'

group :development, :test do
  gem 'sqlite3'
end

group :production do
   gem 'pg'
   gem 'rails_12factor' 
end

gem 'sass-rails', '~> 4.0.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'jquery-rails'
gem 'turbolinks'
gem 'jbuilder', '~> 1.2'
```

sqlite3 gem on siis käytössä ainoastaan development- ja test-ympäristöissä. Ainoastaan tuotantoympäristössä taas käytössä ovat gemit pg ja rails_12factor.


## Tehtävien palautus

Commitoi kaikki tekemäsi muutokset ja pushaa koodi Githubiin. Lisää Githubin readme-tiedostoon linkki sovelluksen Heroku-instanssiin. Oletusarvoisesti Rails-sovelluksen readme-tiedostoon generoituvan sisältö kannattanee poistaa.

Tehtävät kirjataan palautetuksi osoitteeseen http://rorwadstats-2013.herokuapp.com/
