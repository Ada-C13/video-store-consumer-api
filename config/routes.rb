Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  resources :customers, only: [:index]
  
  # TODO: new to add the create action in the movie controller 
  # so that user can add a movie from the search results to the rental library
  resources :movies, only: [:index, :show, :create], param: :title

  post "/rentals/:title/check-out", to: "rentals#check_out", as: "check_out"
  post "/rentals/:title/return", to: "rentals#check_in", as: "check_in"
  get "/rentals/overdue", to: "rentals#overdue", as: "overdue"

  root 'movies#index'

end
