# frozen_string_literal

class PagesController < ApplicationController
  def home
    if user_signed_in?
      redirect_to notes_path(current_user.display_name)
    end
  end
end
