# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Note, type: :model do
  describe '#slug' do
    it 'is generated from the title' do
      title = 'Note Title'
      slug = 'note-title'

      note = FactoryBot.create(:note, title: title)

      expect(note.slug).to eq(slug)
    end

    it 'is updated when the title is changed' do
      old_title = 'Note Title'
      new_title = 'Changed Title'
      new_slug = 'changed-title'

      note = FactoryBot.create(:note, title: old_title)
      note.update!(title: new_title)

      expect(note.slug).to eq(new_slug)
    end

    it 'stays the same when the title is not changed' do
      title = 'Note Title'
      old_slug = 'note-title'

      note = FactoryBot.create(:note, title: title)
      note.update!(body: 'Updated body')

      expect(note.slug).to eq(old_slug)
    end

    it 'cannot be duplicated by the same users' do
      user = FactoryBot.create(:user)

      title = 'My Note'
      slug = 'my-note'
      note1 = FactoryBot.create(:note, user: user, title: title)
      note2 = FactoryBot.create(:note, user: user, title: title)

      expect(note1.slug).to eq(slug)
      expect(note2.slug).not_to eq(slug)
    end
  end
end
