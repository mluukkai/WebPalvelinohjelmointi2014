## Muutamia selvennyksiä

Tutkitaan hetki luokkaa <code>Brewery</code>:

```ruby
class Brewery < ActiveRecord::Base
  has_many :beers
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

Olion ulkopuolelta olion attribuutteihin päästään siis käsiksi 'pistentotaatiolla':
    
    b.year

entä olion sisältä? Tehdään panimolle metodi, joka demonstroi panimon attribuuttien käsittelyä panimon sisältä:

```ruby
class Brewery < ActiveRecord::Base
  has_many :beers

  def print_report
    puts name
    puts "established at year #{year}"
    puts "number of beers #{beers.count}"
  end
end
```
eli olion sisältä metodeja (myös <code>beers</code> on metodi!) voi kutsua kuten esim. javassa, metodin nimellä.

Ja esimerkki metodin käytöstä:

```ruby
irb(main):001:0> b = Brewery.first
irb(main):002:0> b.print_report
Koff
established at year 1897
number of beers 2
```

Metodeja olisi voitu kutsua olion sisältä myös käyttäen Rubyn 'thissiä' eli olion <code>self</code>-viitettä:

```ruby
  def print_report
    puts self.name
    puts "established at year #{self.year}"
    puts "number of beers #{self.beers.count}"
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

Panimon sisällä <code>code</code> siis on ActiveRecordin tietokantaan tallentama attribuutti, kun taas <code>@year</code> on olion instanssimuuttuja. Railsin modeleissa instanssimuutuujia ei juurikaan käytetä. Instanssimuuttujia käytetään Railsissa lähinnä tiedonvälitykseen kontrollereilta näkymille.
