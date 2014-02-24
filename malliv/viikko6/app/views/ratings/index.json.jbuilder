json.array!(@ratings) do |rating|
  json.extract! rating, :id, :score, :beer
end
