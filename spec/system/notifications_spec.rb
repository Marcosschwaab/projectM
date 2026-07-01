require "rails_helper"

RSpec.describe "Notifications", type: :system do
  before { driven_by(:rack_test) }

  it "displays notifications" do
    user, organization = create_user_with_organization.values_at(:user, :organization)
    actor = create(:user)
    project = create(:project, organization:, assignee: user)
    task = create(:task, project:)
    create(:notification, recipient: user, organization:, actor:, action: "task_assigned", notifiable: task)

    sign_in_as(user)
    click_link "Notifications"

    expect(page).to have_text("Notifications")
  end

  it "shows empty state when no notifications" do
    user, organization = create_user_with_organization.values_at(:user, :organization)

    sign_in_as(user)
    click_link "Notifications"

    expect(page).to have_text("No notifications yet")
  end
end
