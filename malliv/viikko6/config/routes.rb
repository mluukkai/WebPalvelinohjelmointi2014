Ratebeer::Application.routes.draw do
  resources :styles

  resources :memberships  do
    post 'activate', on: :member
  end

  resources :beer_clubs

  resources :users

  resources :beers

  resources :breweries do
    post 'toggle_activity', on: :member
  end

  resources :ratings, :only => [:index, :new, :create, :destroy]

  resources :sessions, :only => [:new, :create, :destroy]

  get 'signup', to: 'users#new'
  get 'signin', to: 'sessions#new'
  delete 'signout', to: 'sessions#destroy'

  resources :places, only:[:index, :show]
  post 'places', to:'places#search'

  get 'api/:city', to:'api#search'

  get 'beerlist', to:'beers#list'

  get 'ngbeerlist', to:'beers#nglist'

  get 'brewerylist', to:'breweries#list'

  get 'auth/facebook/callback', to: 'sessions#create_fb'
  get 'auth/failure', to: redirect('/')

  root 'breweries#index'

end
