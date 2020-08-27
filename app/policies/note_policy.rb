# frozen_string_literal: true

class NotePolicy < ApplicationPolicy
  def own_record?
    record.user == user
  end

  alias :create? :own_record?
  alias :update? :own_record?
  alias :destroy? :own_record?
end
