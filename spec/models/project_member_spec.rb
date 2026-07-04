require "rails_helper"

RSpec.describe ProjectMember, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      member = build(:project_member)
      expect(member).to be_valid
    end

    it "requires a role" do
      member = build(:project_member, role: nil)
      expect(member).not_to be_valid
      expect(member.errors[:role]).to include("can't be blank")
    end

    it "validates uniqueness of user per project" do
      project_member = create(:project_member)
      duplicate = build(:project_member, project: project_member.project, user: project_member.user)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:user_id]).to include("is already a team member")
    end
  end

  describe "associations" do
    it "belongs to project" do
      member = create(:project_member)
      expect(member.project).to be_a(Project)
    end

    it "belongs to user" do
      member = create(:project_member)
      expect(member.user).to be_a(User)
    end
  end

  describe "enums" do
    it "defines roles" do
      expect(ProjectMember.roles).to include("member", "manager")
    end
  end
end
