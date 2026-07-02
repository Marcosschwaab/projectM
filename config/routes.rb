Rails.application.routes.draw do
  devise_for :users

  get "locale/:locale", to: "locales#switch", as: :switch_locale

  root "home#index"

  resources :organizations do
    resource :calendar, only: %i[show], controller: :calendars
    resources :invitations, only: %i[new create index]
    resources :tags
    resources :webhooks
    resources :custom_fields
    resources :kpis
    resources :okr_cycles do
      resources :objectives do
        resources :key_results
      end
    end
    resources :projects do
      member do
        patch :archive
      end
      resources :tasks do
        collection do
          patch :bulk_update
          delete :bulk_destroy
        end
        member do
          patch :move
          get :modal
        end
        resources :comments, only: %i[create]
        resources :checklist_items, only: %i[create update destroy]
        resources :time_entries, only: %i[create update destroy] do
          collection do
            post :start
            patch :stop
          end
        end
      end
      resource :kanban, only: %i[show], controller: :kanban
      resource :strategic_canvas, only: %i[show update], controller: :strategic_canvases
    end
  end

  resources :notifications, only: %i[index] do
    member do
      patch :mark_read
    end
    collection do
      patch :mark_all_read
    end
  end

  resource :my_tasks, only: %i[show], controller: :my_tasks
  resource :dashboard, only: %i[show], controller: :dashboard do
    resources :widgets, only: %i[index create update destroy], controller: "dashboard/widgets" do
      collection do
        patch :reorder
      end
    end
  end
  resource :search, only: %i[show], controller: :searches
  resource :report, only: %i[show], controller: :reports

  resource :theme, only: %i[update]

  mount ActionCable.server => "/cable"

  get "up" => "rails/health#show", as: :rails_health_check
end
