class Membership < ActiveRecord::Base
  belongs_to :user
  belongs_to :beer_club

  validates :user, uniqueness: {scope: :beer_club}
end
