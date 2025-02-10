Rails.application.routes.draw do
  get "events/index"
  get "events/new"
  get "events/create"
  root "pages#home"
  get "/home", to: "pages#home"
  get "pages/about"
  get "pages/contact"
  devise_for :users

  resources :users, only: [:index, :show, :edit, :update, :destroy]
  resources :employees
  resources :clients
  resources :projects do
    patch :assign_employees, on: :member
  end
  resources :quotes
  resources :projects do
    resources :quotes
  end
  resources :quotes do
    member do
      post :duplicate
    end
  end
  resources :quotes, only: [:index, :show, :new, :create, :edit, :update, :destroy]
  resources :quotes do
    patch :update_status, on: :member
  end
  resources :quotes do
    resources :items, only: [:create, :edit, :update, :destroy]
  end
  resources :quotes do
    member do
      post :duplicate
    end
  end

  resources :settings, only: [:index, :edit, :update]

  resources :employees do
    resources :events do
      member do
        patch :approve
        patch :reject
      end
    end
  end

  resources :events do
    collection do
      get :pending_count
    end
  end

  resources :employees do
    get 'check_availability', on: :collection
  end
  resources :events do
    collection do
      get :approved_overtime_hours
    end
  end
  resources :employees do
    resources :expenses do
      member do
        patch :approve
        patch :reject
      end
    end
  end

  resources :employees do
    member do
      get 'expenses_by_year'
    end
  end
  resources :expenses, except: [:show] do
    collection do
      get :pending_count2
      get :global_expenses_by_date
    end
  end




end
