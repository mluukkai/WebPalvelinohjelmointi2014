module RatingAverage
  def average_rating
    ratings.average :score
  end
end