Rails.application.routes.draw do
  mount Qubit::Engine => "/qubit"

  resources :examples, only: [:show]
end
