require "rails_helper"

RSpec.describe "Calendar", type: :system do
  before { driven_by(:rack_test) }

  it "displays the calendar" do
    user = create(:user)
    organization = create(:organization)
    create(:organization_membership, user:, organization:, role: :admin)
    project = create(:project, organization:, assignee: user)
    create(:task, project:, title: "Design review", due_date: Date.tomorrow)

    sign_in_as(user)
    click_link "Calendar"

    expect(page).to have_text("Calendar")
    expect(page).to have_text(I18n.t("date.abbr_day_names")[Date.today.wday])
  end
end
