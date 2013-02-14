Dvt::Application.routes.draw do

  get 'login'   => 'sessions#new',      :as => 'login'
  get 'logout'  => 'sessions#destroy',  :as => 'logout'

  # Used by Anchor load balancer to check health of web server
  get 'heartbeat' => 'heartbeat#index'

  # Searches both LPI and LGA records.
  get "search" => "search#index"

  resource :profile, :only => [:edit, :update]

  resources :sessions, :only => [:new, :create]

  resources :users, :only => [:index, :show, :new, :create, :edit, :update] do
    collection do
      get 'admin'
    end
  end

  resource :land_parcel_record,
    :controller => :land_parcel_records, :path => :land_parcels, :only => [] do
      get '*id', :action => :show, :as => :show
  end

  resources :local_government_areas, :only => [:index, :show, :new, :create, :edit, :update] do

    resources :details,
      :controller => 'local_government_area_record_import_logs',
      :only => [:show]

    member do
      post 'uploads'
      post 'import'
      get 'error_records'
      get 'only_in_council'
      get 'only_in_lpi'
    end
  end

  resources :reset_passwords, :only => [:new, :create, :edit, :update]

  root :to => 'local_government_areas#index'

end
