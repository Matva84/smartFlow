Rails.application.routes.draw do
  root to: "pages#home"
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
end
