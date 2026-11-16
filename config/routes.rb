Rails.application.routes.draw do
  namespace :api do
    get "schema/book", to: "schema#book"
    get "schema/tag",  to: "schema#tag"
  end

  get "tags/index"
  resources :tags, only: [:index, :show, :destroy]
  resources :books do
    collection do
      post :scan
    end
  end

  root "books#index"

  get "up" => "rails/health#show", as: :rails_health_check

  # SPA fallback: serve the Funicular host page for direct HTML visits/refreshes
  # (ignores .json API requests, /api/*, /up, and /rails/* Active Storage URLs)
  get "*path", to: "books#index", constraints: ->(req) do
    req.format.html? &&
      !req.path.start_with?("/rails/", "/api/", "/up")
  end
end