Rails.application.routes.draw do
  # redirect slapdash.info to slapdash.codingitwrong.com
  get "/(*path)",
    to: redirect { |path_params, request|
      "https://slapdash.codingitwrong.com/#{path_params[:path]}"
    },
    status: 302,
    constraints: {domain: "slapdash.info"}

  devise_for :users, controllers: {
    registrations: "users/registrations"
  }

  root "pages#home"

  get "/:user_display_name", to: "notes#index", as: :notes
  get "/:user_display_name/notes/new", to: "notes#new", as: :new_note
  post "/:user_display_name", to: "notes#create"
  get "/:user_display_name/:note_slug", to: "notes#show", as: :note
  get "/:user_display_name/:note_slug/edit", to: "notes#edit", as: :edit_note
  patch "/:user_display_name/:note_slug", to: "notes#update", as: :update_note
  delete "/:user_display_name/:note_slug", to: "notes#destroy"
end
