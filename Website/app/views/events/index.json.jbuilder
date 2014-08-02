json.array!(@events) do |event|
  json.extract! event, :id, :name, :venue, :latitude, :longitude, :from, :until, :content, :image, :type
  json.url event_url(event, format: :json)
end
