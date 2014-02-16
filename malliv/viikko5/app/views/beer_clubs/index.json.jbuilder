json.array!(@beer_clubs) do |beer_club|
  json.extract! beer_club, :id, :name, :founded, :city
  json.url beer_club_url(beer_club, format: :json)
end
