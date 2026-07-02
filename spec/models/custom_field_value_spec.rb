require "rails_helper"

RSpec.describe CustomFieldValue, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      value = build(:custom_field_value)
      expect(value).to be_valid
    end

    it "validates value is a number for number type" do
      field = create(:custom_field, field_type: "number")
      value = build(:custom_field_value, custom_field: field, value: "abc")
      expect(value).not_to be_valid
    end

    it "validates value is a valid date for date type" do
      field = create(:custom_field, field_type: "date")
      value = build(:custom_field_value, custom_field: field, value: "not-a-date")
      expect(value).not_to be_valid
    end

    it "validates value is in options for select type" do
      field = create(:custom_field, field_type: "select", options: ["Option A", "Option B"])
      value = build(:custom_field_value, custom_field: field, value: "Option C")
      expect(value).not_to be_valid
    end
  end

  describe "associations" do
    it "belongs to custom_field" do
      value = create(:custom_field_value)
      expect(value.custom_field).to be_a(CustomField)
    end

    it "belongs to customizable" do
      value = create(:custom_field_value)
      expect(value.customizable).to be_a(Task)
    end
  end
end
