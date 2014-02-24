json.array!(@memberships) do |membership|
  json.extract! membership, :id, :beer_club_id, :user_id
  json.url membership_url(membership, format: :json)
end
