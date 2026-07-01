require "rails_helper"

RSpec.describe Comment, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      comment = build(:comment)
      expect(comment).to be_valid
    end

    it "requires content" do
      comment = build(:comment, content: nil)
      expect(comment).not_to be_valid
      expect(comment.errors[:content]).to include("can't be blank")
    end
  end

  describe "associations" do
    it "belongs to task" do
      comment = create(:comment)
      expect(comment.task).to be_a(Task)
    end

    it "belongs to user" do
      comment = create(:comment)
      expect(comment.user).to be_a(User)
    end
  end
end
