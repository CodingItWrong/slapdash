require 'rails_helper'

RSpec.describe 'Viewing Notes', type: :system do
  before do
    driven_by(:rack_test)
  end

  it 'allows viewing a note' do
    user_name = 'someuser'
    note_title = 'Note Title'
    note_slug = 'note-title'
    note_body = 'This is the note body.'

    user = FactoryBot.create(:user, display_name: user_name)
    note = FactoryBot.create(
      :note,
      user: user,
      title: note_title,
      body: note_body,
    )

    visit "/#{user_name}/#{note_slug}"

    expect(page).to have_content(note_title)
    expect(page).to have_content(note_body)
  end
end
