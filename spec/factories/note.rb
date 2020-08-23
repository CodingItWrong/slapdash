# frozen_string_literal: true

FactoryBot.define do
  factory :note do
    sequence(:title) { |n| "Note #{n}" }
    sequence(:body) { |n| "Body of note #{n}" }
  end
end
