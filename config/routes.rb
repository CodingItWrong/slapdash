Rails.application.routes.draw do
  devise_for :users

  get '/:user_display_name', to: 'notes#index', as: :notes
  get '/:user_display_name/notes/new', to: 'notes#new', as: :new_note
  post '/:user_display_name', to: 'notes#create'
  get '/:user_display_name/:note_slug', to: 'notes#show', as: :note
  get '/:user_display_name/:note_slug/edit', to: 'notes#edit', as: :edit_note
  patch '/:user_display_name/:note_slug', to: 'notes#update', as: :update_note
end
