class User < ActiveRecord::Base
  include RatingAverage

  validates :username, uniqueness: true,
                       length: { in: 3..20 }

  validates :password, length: { minimum: 3 },
                       format: { with: /.*(\d.*[A-Z]|[A-Z].*\d).*/,
                                 message: "should contain a uppercase letter and a number" }

  has_secure_password

  has_many :ratings, dependent: :destroy
  has_many :beers, through: :ratings
  has_many :memberships, dependent: :destroy

  has_many :confirmed_memberships, ->{ where( confirmed: true) }, class_name: 'Membership'
  has_many :applications, ->{ where( confirmed: [nil, false]) }, class_name: 'Membership'

  has_many :beer_clubs, through: :confirmed_memberships
  has_many :outstanding_club_applications, through: :applications, source: :beer_club

  def self.top(n)
    sorted_by_rating_in_desc_order = self.all.sort_by{ |b| -(b.ratings.count||0)  }
    sorted_by_rating_in_desc_order[0..n-1]
  end

  def favorite_beer
    return nil if ratings.empty?
    #ratings.order(score: :desc).limit(1).first.beer
    ratings.sort_by{ |r| r.score }.last.beer
  end

  def favorite_brewery
    favorite :brewery
  end

  def favorite_style
    favorite :style
  end

  private

  def favorite(category)
    return nil if ratings.empty?
    rating_pairs = rated(category).inject([]) do |pairs, item|
      pairs << [item, rating_average(category, item)]
    end
    rating_pairs.sort_by { |s| s.last }.last.first
  end

  def rated(category)
    ratings.map{ |r| r.beer.send(category) }.uniq
  end

  def rating_average(category, item)
    ratings_of_item = ratings.select{ |r|r.beer.send(category)==item }
    return 0 if ratings_of_item.empty?
    ratings_of_item.inject(0.0){ |sum ,r| sum+r.score } / ratings_of_item.count
  end

end
