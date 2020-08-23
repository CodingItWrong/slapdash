Rails.application.routes.draw do
  devise_for :users
  get '/:user_display_name/:note_slug', to: 'notes#show'
end
