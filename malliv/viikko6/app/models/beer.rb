class Beer < ActiveRecord::Base
  include RatingAverage

  validates :name, presence: true
  validates :style, presence: true

  belongs_to :style
	belongs_to :brewery, touch: true
  has_many :ratings, dependent: :destroy
  has_many :raters, -> { uniq }, through: :ratings, source: :user

  def self.top(n)
    sorted_by_rating_in_desc_order = self.all.sort_by{ |b| -(b.average_rating||0)  }
    sorted_by_rating_in_desc_order[0..n-1]
  end

  def to_s
    "#{name} #{brewery.name}"
  end
end
