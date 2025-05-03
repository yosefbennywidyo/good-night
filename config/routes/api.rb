namespace :api do
  namespace :v1 do
    resources :users do
      resources :followings, only: [ :index, :create, :destroy ]
    end
  end
end
