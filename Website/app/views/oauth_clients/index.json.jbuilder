json.array!(@popular) do |app|
  json.extract! app, :id, :name, :website, :support_url, :callback_url, :icon_16, :icon_64, :description, :author, :author_url
  json.url app_url(app, format: :json)
end