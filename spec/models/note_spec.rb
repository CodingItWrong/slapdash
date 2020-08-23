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
  end
end
