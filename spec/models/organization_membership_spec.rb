require "rails_helper"

RSpec.describe OrganizationMembership, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      membership = build(:organization_membership)
      expect(membership).to be_valid
    end

    it "requires a role" do
      membership = build(:organization_membership, role: nil)
      expect(membership).not_to be_valid
      expect(membership.errors[:role]).to include("can't be blank")
    end

    it "validates uniqueness of user per organization" do
      user = create(:user)
      org = create(:organization)
      create(:organization_membership, user: user, organization: org)
      duplicate = build(:organization_membership, user: user, organization: org)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:user_id]).to include("is already a member")
    end
  end

  describe "associations" do
    it "belongs to organization" do
      membership = create(:organization_membership)
      expect(membership.organization).to be_a(Organization)
    end

    it "belongs to user" do
      membership = create(:organization_membership)
      expect(membership.user).to be_a(User)
    end
  end

  describe "enums" do
    it "defines roles" do
      expect(OrganizationMembership.roles).to include("member", "manager", "admin")
    end
  end
end
