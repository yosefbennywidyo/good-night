namespace :api do
  namespace :v1 do
    resources :users do
      resources :followings, only: [ :index, :create, :destroy ]

      resources :sleep_records, only: [ :index ] do
        collection do
          post :clock_in
          get :following_records
        end

        member do
          post :clock_out
        end
      end
    end
  end
end
