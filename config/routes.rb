Rails.application.routes.draw do
  devise_for :users

  root "home#index"

  resources :organizations do
    resources :invitations, only: %i[new create index]
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
