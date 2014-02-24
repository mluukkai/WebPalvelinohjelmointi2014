class BeerClub < ActiveRecord::Base
  has_many :memberships
  has_many :confirmed_memberships, ->{ where( confirmed: true) }, class_name: 'Membership'
  has_many :applications, ->{ where( confirmed: [nil, false]) }, class_name: 'Membership'

  has_many :members, through: :confirmed_memberships, source: :user
  has_many :applicants, through: :applications, source: :user

  def member?(user)
    return false if user.nil?
    members.include? user
  end
end
