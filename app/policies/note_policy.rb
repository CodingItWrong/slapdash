# frozen_string_literal: true

class NotePolicy < ApplicationPolicy
  def own_record?
    record.user == user
  end

  alias_method :create?, :own_record?
  alias_method :update?, :own_record?
  alias_method :destroy?, :own_record?
end
