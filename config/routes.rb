Dvt::Application.routes.draw do
  get 'login'   => 'sessions#new',      :as => 'login'
  get 'logout'  => 'sessions#destroy',  :as => 'logout'

  resources :sessions, :only => [:new, :create]
  resources :users, :only => [:index, :show, :new, :create, :edit, :update]

  root :to => 'users#index'

end
