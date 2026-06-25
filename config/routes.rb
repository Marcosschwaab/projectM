Rails.application.routes.draw do
  devise_for :users

  root "home#index"

  resources :organizations do
    resources :invitations, only: %i[new create index]
    resources :projects do
      member do
        patch :archive
      end
      resources :tasks do
        member do
          patch :move
        end
        resources :comments, only: %i[create]
        resources :checklist_items, only: %i[create update destroy]
      end
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
