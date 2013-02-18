Dvt::Application.routes.draw do
  get 'login'   => 'sessions#new',      :as => 'login'
  get 'logout'  => 'sessions#destroy',  :as => 'logout'

  # Used by Anchor load balancer to check health of web server
  get 'heartbeat' => 'heartbeat#index'

  resource :profile, :only => [:edit, :update]

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
      post 'import'
      get 'error_records'
      get 'only_in_council'
      get 'only_in_lpi'
    end
    resources :details,
      :controller => 'local_government_area_record_import_logs',
      :only => [:show]
  end

  resources :land_parcel, :only => [:index], controller: 'mockup_land_parcel' do
    member do
      get 'valid_dp'
      get 'valid_sp'
      get 'valid_sp_cp'
      get 'only_in_council_dp'
      get 'only_in_council_sp'
      get 'only_in_council_sp_cp'
      get 'only_in_lpi'
      get 'invalid_one'
      get 'invalid_multiple'
      get 'in_multiple_lgas'
      get 'inconsistent_sp'
      get 'inconsistent_sp_cp'
      get 'duplicate_dp'
    end
  end


  resources :reset_passwords, :only => [:new, :create, :edit, :update]

  root :to => 'local_government_areas#index'

end
