require 'rails_helper'

RSpec.describe 'Viewing Notes', type: :system do
  before do
    driven_by(:rack_test)
  end

  it 'allows adding a note' do
    note_title = 'Note Title'
    note_slug = 'note-title'
    note_body = 'This is the note body.'

    user = FactoryBot.create(:user)

    visit "/#{user.display_name}"

    click_on 'Add'

    fill_in 'Title', with: note_title
    fill_in 'Body', with: note_body
    click_on 'Save'

    expect(page).to have_current_path(
      "/#{user.display_name}/#{note_slug}"
    )
    expect(page).to have_content(note_title)
    expect(page).to have_content(note_body)
  end

  it 'allows editing a note' do
    old_title = 'Note Title'
    old_slug = 'note-title'
    old_body = 'This is the note body.'

    new_title = 'New Title'
    new_slug = 'new-title'
    new_body = 'This is the new body.'

    user = FactoryBot.create(:user)
    note = FactoryBot.create(
      :note,
      user: user,
      title: old_title,
      body: old_body,
    )

    visit "/#{user.display_name}/#{old_slug}"

    click_on 'Edit'

    fill_in 'Title', with: new_title
    fill_in 'Body', with: new_body
    click_on 'Save'

    expect(page).not_to have_content(old_title)
    expect(page).not_to have_content(old_body)

    expect(page).to have_content(new_title)
    expect(page).to have_content(new_body)
  end

  it 'allows deleting a note' do
    note_title = 'Note Title'

    user = FactoryBot.create(:user)
    note = FactoryBot.create(
      :note,
      user: user,
      title: note_title,
    )

    visit "/#{user.display_name}/#{note.slug}"

    click_on 'Delete'

    expect(page).to have_current_path(
      "/#{user.display_name}"
    )
    expect(page).not_to have_content(note_title)
  end
end
