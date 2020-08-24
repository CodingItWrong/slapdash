require 'rails_helper'

RSpec.describe 'Managing Notes', type: :system do
  include Devise::Test::IntegrationHelpers

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

    # validation errors
    click_on 'Save'
    expect(page).to have_content("Title can't be blank")

    # successful submission
    fill_in 'Title', with: note_title
    fill_in 'Body', with: note_body
    click_on 'Save'

    expect(page).to have_current_path(
      "/#{user.display_name}/#{note_slug}"
    )
    expect(page).to have_content(note_title)
    expect(page).to have_content(note_body)
    expect(page).to have_content('Note created')

    visit "/#{user.display_name}"
    expect(page).to have_content(note_title)
  end

  context 'editing' do
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

      sign_in user
      visit "/#{user.display_name}/#{old_slug}"

      click_on 'Edit'

      # validation errors
      fill_in 'Title', with: ''
      click_on 'Save'
      expect(page).to have_current_path(
        "/#{user.display_name}/#{old_slug}"
      )
      expect(page).to have_content("Title can't be blank")

      # successful submission
      fill_in 'Title', with: new_title
      fill_in 'Body', with: new_body
      click_on 'Save'

      expect(page).to have_current_path(
        "/#{user.display_name}/#{new_slug}"
      )

      expect(page).not_to have_content(old_title)
      expect(page).not_to have_content(old_body)

      expect(page).to have_content(new_title)
      expect(page).to have_content(new_body)
      expect(page).to have_content('Note updated')
    end

    it "does not allow editing another user's note" do
      user = FactoryBot.create(:user)
      other_user = FactoryBot.create(:user)
      other_user_note = FactoryBot.create(:note, user: other_user)

      visit "/#{other_user.display_name}/#{other_user_note.slug}"

      # edit link hidden
      expect(page).not_to have_content('Edit')

      # edit page request fails
      expect {
        visit "/#{other_user.display_name}/#{other_user_note.slug}/edit"
      }.to raise_error(Pundit::NotAuthorizedError)

      # direct patch fails
      expect {
        patch "/#{other_user.display_name}/#{other_user_note.slug}"
      }.to raise_error(Pundit::NotAuthorizedError)
    end
  end

  context 'deleting' do
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
      expect(page).to have_content('Note deleted')
    end
  end
end
