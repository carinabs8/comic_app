Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :book_covers, only: [:index] do
    post :search, on: :collection
    post :upvote
  end
end
