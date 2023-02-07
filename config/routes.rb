Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  namespace :api do
    namespace :v1 do
      resources :sessions, only: %i[create index]
      resources :restaurants, only: %i[index show update destroy create]
      resources :reviews, only: %i[index show update destroy create]
    end
  end

  post 'api/v1/sessions/signin', to: 'api/v1/sessions#signin'
  root 'homepage#index'
  get '/*path' => 'homepage#index' 
end
