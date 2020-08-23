require 'rails_helper'

RSpec.describe 'Viewing Notes', type: :system do
  before do
    driven_by(:rack_test)
  end

  it 'allows navigating directly to a note' do
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

    expect(page).to have_current_path(
      "/#{user.display_name}/#{note_slug}"
    )
    expect(page).to have_content(note_title)
    expect(page).to have_content(note_body)
  end

  it "allows listing a user's notes" do
    user = FactoryBot.create(:user)
    user_note = FactoryBot.create(:note, user: user)
    other_user_note = FactoryBot.create(:note)

    visit "/#{user.display_name}"

    expect(page).not_to have_content(other_user_note.title)

    click_on user_note.title

    expect(page).to have_current_path(
      "/#{user.display_name}/#{user_note.slug}"
    )
    expect(page).to have_content(user_note.title)
    expect(page).to have_content(user_note.body)
  end

  it "allows viewing another user's notes" do
    user = FactoryBot.create(:user)
    other_user = FactoryBot.create(:user)
    other_user_note = FactoryBot.create(:note, user: other_user)

    visit "/#{other_user.display_name}"
    click_on other_user_note.title

    expect(page).to have_content(other_user_note.title)
    expect(page).to have_content(other_user_note.body)
  end
end
