json.array!(@popular) do |event|
  json.extract! event, :id, :name, :venue, :latitude, :longitude, :start, :stop, :content, :category
  json.url event_url(event, format: :json)
end
