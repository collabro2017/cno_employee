CNO::RailsApp.routes.draw do
  
  resources :datasource_restricted_companies do
    collection do
      delete 'destroy_all_by_datasource'
    end
  end

  resources :companies do
    collection do
      get 'restricted_by_datasource'
    end
  end

  ##############################################################################
  # These two are at the top because if not, by default the routing confused
  # them with '/{resource}/[:id]' and calls the show action
  resources :lookups do
    get 'filtered_values', on: :collection
  end

  resources :user_files do
    get '__user_files', on: :collection

    member do
      patch  'mark_as_uploaded'
      delete 'soft_destroy'
    end
  end
  ##############################################################################

  resources :selects do
    member do
      get 'get_saved_enter_values'
      patch 'update_position'
      patch 'add_value'
      patch 'remove_value'
      patch 'update_single_value'
      patch 'add_all_select_option_values'
      patch 'remove_all_select_option_values'
      patch 'add_multiple_lookup_values'
      patch 'remove_multiple_lookup_values'
      patch 'add_all_lookup_values'
      patch 'remove_all_lookup_values'
      patch 'add_multiple_enter_values'
      patch 'set_range'
      patch 'reset_range'
      patch 'set_date'
      patch 'reset_date'
      patch 'set_blanks'
      patch 'reset_blanks'
      patch 'set_exclude'
      patch 'reset_exclude'
      patch 'add_user_file'
      patch 'remove_user_file'
      patch 'add_link'
      patch 'remove_link'
    end

    resources :user_files, shallow: true do
      get '__select_user_files', on: :collection
    end
  end

  resources :breakdowns

  resources :dedupes

  resources :outputs

  resources :sorts

  resources :two_factor_auth, only: [:index, :create] do
    collection do
      post :resend_code
    end
  end

  resources :counts do
    member do
      get   '__count_sql'
      get   '__status_and_result'
      get   '__breakdown_result'
      get   '__suppression_orders'
      get   '__clone_status'
      get   'new_clone'
      patch 'rename'
      post  'clone'
      patch 'add_suppression_order'
      patch 'remove_suppression_order'
      patch 'ignore_clone'
      patch 'retry_clone'
    end

    resources :user_files, shallow: true do
      get '__suppression_user_files', on: :collection
    end
  end

  resources :counts_user_files

  resources :orders do
    member do
      get   '__order_result'
      get   'place'
    end
  end
  
  resources :jobs do
    member do
      get 'check_status'
    end
  end

  resources :concrete_fields, shallow: true do
    resources :select_options
  end

  root to: 'sessions#new', via: 'get'

  match '/signin',            to: 'sessions#new',               via: 'get'
  match '/signout',           to: 'sessions#destroy',           via: 'delete'
  match '/server_time',       to: 'counts#server_time',         via: 'get'
  match '/activate_account',  to: 'sessions#activate_account',  via: 'get'
  match '/confirm_account',   to: 'sessions#confirm_account',   via: 'patch'
  match '/confirm_email',     to: 'sessions#confirm_email',     via: 'patch'
  match '/new_password',      to: 'sessions#new_password',      via: 'get'
  match '/set_password',      to: 'sessions#set_password',      via: 'patch'
  match '/reset_password',    to: 'sessions#reset_password',    via: 'get'

  resources :datasources do
    member do
      get 'edit_access_level'
    end
  end

  resources :users do
    member do
      patch 'resend_activation_email'
    end
  end

  resources :sessions, only: [:new, :create, :destroy] do
    collection do
      get  'check_time_left'
      get  'reset_password'
    end
  end

end