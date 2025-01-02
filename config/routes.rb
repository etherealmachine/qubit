Qubit::Engine.routes.draw do
  resources :tests do
    member do
      patch :launch
    end
    resources :variants do
      member do
        patch :close
        patch :override
      end
    end
  end

  resources :conditions

  resources :holdouts

  resources :censuses
  
  root "tests#index"
end
