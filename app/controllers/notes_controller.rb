# frozen_string_literal: true

class NotesController < ApplicationController
  before_action :populate_user
  before_action :populate_note, except: %i[index new create]

  def index
    @notes = @user.notes.order("LOWER(title)")
    @note = @user.notes.build
  end

  def new
    @note = @user.notes.build
    authorize @note
  end

  def create
    @note = @user.notes.create(note_params)
    authorize @note
    if @note.save
      redirect_to note_path(@user.display_name, @note.slug), notice: "Note created"
    else
      render :new
    end
  end

  def show
  end

  def edit
    authorize @note
  end

  def update
    authorize @note
    if @note.update(note_params)
      redirect_to note_path(@user.display_name, @note.slug), notice: "Note updated"
    else
      @note.restore_attributes([:slug])
      render :edit
    end
  end

  def destroy
    authorize @note
    @note.destroy
    redirect_to notes_path, notice: "Note deleted"
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
