require "rails_helper"

RSpec.describe CustomField, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      field = build(:custom_field)
      expect(field).to be_valid
    end

    it "requires name" do
      field = build(:custom_field, name: nil)
      expect(field).not_to be_valid
    end

    it "requires field_type" do
      field = build(:custom_field, field_type: nil)
      expect(field).not_to be_valid
    end

    it "validates field_type inclusion" do
      field = build(:custom_field, field_type: "invalid")
      expect(field).not_to be_valid
    end

    it "validates uniqueness of name scoped to organization" do
      org = create(:organization)
      create(:custom_field, organization: org, name: "Size")
      dup = build(:custom_field, organization: org, name: "Size")
      expect(dup).not_to be_valid
    end
  end

  describe "associations" do
    it "belongs to organization" do
      field = create(:custom_field)
      expect(field.organization).to be_a(Organization)
    end
  end
end
