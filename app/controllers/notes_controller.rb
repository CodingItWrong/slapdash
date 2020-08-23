# frozen_string_literal

class NotesController < ApplicationController
  before_action :populate_user_and_note, only: [:show, :edit, :update]

  def show
  end

  def edit
  end

  def update
    @note.update(note_params)
    redirect_to note_path(@user.display_name, @note.slug) # TODO flash message
  end

  private

  def note_params
    params.require(:note).permit(:title, :body)
  end

  def populate_user_and_note
    @user = User.find_by(display_name: params[:user_display_name])
    if @user.present?
      @note = @user.notes.friendly.find(params[:note_slug])
    end
  end
end
