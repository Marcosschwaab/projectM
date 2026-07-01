require "rails_helper"

RSpec.describe Invitation, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      invitation = build(:invitation)
      expect(invitation).to be_valid
    end

    it "requires an email" do
      invitation = build(:invitation, email: nil)
      expect(invitation).not_to be_valid
      expect(invitation.errors[:email]).to include("can't be blank")
    end

    it "auto-generates a token before validation" do
      invitation = build(:invitation, token: nil)
      invitation.valid?
      expect(invitation.token).to be_present
    end

    it "validates uniqueness of token" do
      create(:invitation, token: "abc123")
      duplicate = build(:invitation, token: "abc123")
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:token]).to include("has already been taken")
    end
  end

  describe "associations" do
    it "belongs to organization" do
      invitation = create(:invitation)
      expect(invitation.organization).to be_a(Organization)
    end

    it "belongs to user" do
      invitation = create(:invitation)
      expect(invitation.user).to be_a(User)
    end
  end

  describe "enums" do
    it "defines roles" do
      expect(Invitation.roles).to include("member", "manager", "admin")
    end
  end

  describe "scopes" do
    it "pending returns unaccepted invitations that are not expired" do
      pending = create(:invitation, accepted: false, expires_at: 1.day.from_now)
      expired = create(:invitation, accepted: false, expires_at: 1.day.ago)
      accepted = create(:invitation, accepted: true)
      expect(Invitation.pending).to include(pending)
      expect(Invitation.pending).not_to include(expired)
      expect(Invitation.pending).not_to include(accepted)
    end

    it "expired returns unaccepted invitations past expiry" do
      expired = create(:invitation, accepted: false, expires_at: 1.day.ago)
      expect(Invitation.expired).to include(expired)
    end
  end

  describe "#accept!" do
    it "marks invitation as accepted" do
      invitation = create(:invitation, accepted: false)
      invitation.accept!
      expect(invitation.reload.accepted).to be true
    end
  end

  describe "#expired?" do
    it "returns true when expires_at is in the past" do
      invitation = build(:invitation, expires_at: 1.day.ago)
      expect(invitation).to be_expired
    end

    it "returns false when expires_at is in the future" do
      invitation = build(:invitation, expires_at: 1.day.from_now)
      expect(invitation).not_to be_expired
    end

    it "returns false when expires_at is nil" do
      invitation = build(:invitation, expires_at: nil)
      expect(invitation).not_to be_expired
    end
  end

  describe "before_validation" do
    it "generates a token on create" do
      invitation = build(:invitation, token: nil)
      invitation.valid?
      expect(invitation.token).to be_present
    end
  end
end
