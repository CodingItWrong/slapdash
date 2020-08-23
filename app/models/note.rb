class Note < ApplicationRecord
  extend FriendlyId

  belongs_to :user
  friendly_id :title, use: :slugged

  validates :title, presence: true
end
