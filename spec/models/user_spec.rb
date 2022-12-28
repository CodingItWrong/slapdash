# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  describe "#display_name" do
    valid_display_name = "josh82"

    it "is valid with a good value present" do
      user = FactoryBot.build(:user, display_name: valid_display_name)
      expect(user).to be_valid
    end

    it "is required" do
      user = FactoryBot.build(:user, display_name: "")
      expect(user).not_to be_valid
    end

    it "must be unique" do
      FactoryBot.create(:user, display_name: valid_display_name)
      duplicate_user = FactoryBot.build(:user, display_name: valid_display_name)

      expect(duplicate_user).not_to be_valid
    end

    it "cannot be longer than 24 characters" do
      too_long = "A" * 25
      user = FactoryBot.build(:user, display_name: too_long)

      expect(user).not_to be_valid

      messages = user.errors.full_messages_for(:display_name)
      expect(messages).to eq(["Display name is too long (maximum is 24 characters)"])
    end

    it "cannot be shorter than 3 characters" do
      too_short = "A" * 2
      user = FactoryBot.build(:user, display_name: too_short)
      expect(user).not_to be_valid

      messages = user.errors.full_messages_for(:display_name)
      expect(messages).to eq(["Display name is too short (minimum is 3 characters)"])
    end

    context "valid characters" do
      it "does not allow special characters like asterisks" do
        invalid_name = "user*1"
        user = FactoryBot.build(:user, display_name: invalid_name)
        expect(user).not_to be_valid
      end

      it "does not allow underscores" do
        invalid_name = "user_1"
        user = FactoryBot.build(:user, display_name: invalid_name)
        expect(user).not_to be_valid
      end

      it "does not allow dashes" do
        invalid_name = "user-1"
        user = FactoryBot.build(:user, display_name: invalid_name)
        expect(user).not_to be_valid
      end

      it "does not allow emoji" do
        invalid_name = "user🥴"
        user = FactoryBot.build(:user, display_name: invalid_name)
        expect(user).not_to be_valid
      end

      it "does not allow non-ascii characters" do
        invalid_name = "usér"
        user = FactoryBot.build(:user, display_name: invalid_name)
        expect(user).not_to be_valid
      end
    end
  end
end
