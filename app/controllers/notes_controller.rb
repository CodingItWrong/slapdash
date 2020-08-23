# frozen_string_literal

class NotesController < ApplicationController
  def show
    @user = User.find_by(display_name: params[:user_display_name])
    @note = @user.notes.friendly.find(params[:note_slug])
  end
end
