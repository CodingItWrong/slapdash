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

    context 'uniqueness' do
      let(:user1) { FactoryBot.create(:user) }
      let(:user2) { FactoryBot.create(:user) }
      let(:title) { 'My Note' }
      let(:slug) { 'my-note' }

      it 'cannot be duplicated by the same users' do
        note1 = FactoryBot.create(:note, user: user1, title: title)
        note2 = FactoryBot.create(:note, user: user1, title: title)

        expect(note1.slug).to eq(slug)
        expect(note2.slug).not_to eq(slug)
      end

      it 'can be duplicated across users' do
        user1note = FactoryBot.create(:note, user: user1, title: title)
        user2note = FactoryBot.create(:note, user: user2, title: title)

        expect(user1note.slug).to eq(slug)
        expect(user2note.slug).to eq(slug)
      end
    end
  end
end
