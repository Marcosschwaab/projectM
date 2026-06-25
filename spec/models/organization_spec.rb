require "rails_helper"

RSpec.describe Organization, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      org = build(:organization)
      expect(org).to be_valid
    end

    it "requires a name" do
      org = build(:organization, name: nil)
      expect(org).not_to be_valid
      expect(org.errors[:name]).to include("can't be blank")
    end
  end

  describe "associations" do
    it "has many memberships" do
      org = create(:organization)
      membership = create(:organization_membership, organization: org)
      expect(org.memberships).to include(membership)
    end

    it "has many members through memberships" do
      org = create(:organization)
      user = create(:user)
      create(:organization_membership, organization: org, user: user)
      expect(org.members).to include(user)
    end

    it "has many invitations" do
      org = create(:organization)
      user = create(:user)
      invitation = org.invitations.create!(email: "test@test.com", token: "abc", user: user)
      expect(org.invitations).to include(invitation)
    end

    it "has many projects" do
      org = create(:organization)
      project = create(:project, organization: org)
      expect(org.projects).to include(project)
    end

    it "has many okr cycles" do
      org = create(:organization)
      cycle = org.okr_cycles.create!(title: "Test Cycle")
      expect(org.okr_cycles).to include(cycle)
    end
  end
end
