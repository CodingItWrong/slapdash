# frozen_string_literal

class NotesController < ApplicationController
  before_action :populate_user
  before_action :populate_note, except: [:index, :new, :create]

  def index
    @notes = @user.notes
  end

  def new
    @note = Note.new(user: @user)
  end

  def create
    @note = @user.notes.create(note_params)
    redirect_to note_path(@user.display_name, @note.slug)
  end

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

  def populate_user
    @user = User.find_by(display_name: params[:user_display_name])
  end

  def populate_note
    if @user.present?
      @note = @user.notes.friendly.find(params[:note_slug])
    end
  end
end
