# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :notes

  validates :display_name,
    presence: true,
    uniqueness: true,
    length: { maximum: 24 },
    format: { with: /\A[a-zA-Z0-9]+\Z/ }
end
