Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'homepages#index'

  resources :customers, only: [:index]
  
  # TODO: new to add the create action in the movie controller 
  # so that user can add a movie from the search results to the rental library
  resources :movies, only: [:show, :create], param: :title
  get "/library", to: "movies#index", as: "library"
  get "/input", to: "movies#search_input", as: "search_input"
  get "/search", to: "movies#search", as: "search"
  post "/rentals/:title/check-out", to: "rentals#check_out", as: "check_out"
  post "/rentals/:title/return", to: "rentals#check_in", as: "check_in"
  get "/rentals/overdue", to: "rentals#overdue", as: "overdue"

  

end
