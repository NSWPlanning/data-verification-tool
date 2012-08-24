Dvt::Application.routes.draw do
  get 'login'   => 'sessions#new',      :as => 'login'
  get 'logout'  => 'sessions#destroy',  :as => 'logout'

  # Used by Anchor load balancer to check health of web server
  get 'heartbeat' => 'heartbeat#index'

  resources :sessions, :only => [:new, :create]

  resources :users, :only => [:index, :show, :new, :create, :edit, :update] do
    collection do
      get 'admin'
    end
  end

  resources :local_government_areas,
            :only => [:index, :show, :new, :create, :edit, :update] do
    member do
      post 'uploads'
    end
  end

  resources :reset_passwords, :only => [:new, :create, :edit, :update]

  root :to => 'local_government_areas#index'

end
