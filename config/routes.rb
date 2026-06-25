Rails.application.routes.draw do
  devise_for :users

  root "home#index"

  resources :organizations do
    resources :invitations, only: %i[new create index]
    resources :okr_cycles
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
      resource :kanban, only: %i[show], controller: :kanban
      resource :strategic_canvas, only: %i[show update], controller: :strategic_canvases
    end
  end

  resource :dashboard, only: %i[show], controller: :dashboard

  get "up" => "rails/health#show", as: :rails_health_check
end
