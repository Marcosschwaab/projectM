require "rails_helper"

RSpec.describe "Reports", type: :system do
  before { driven_by(:rack_test) }

  it "displays reports with stats" do
    user = create(:user)
    organization = create(:organization)
    create(:organization_membership, user:, organization:, role: :admin)
    project = create(:project, organization:, name: "Report Project", status: :completed)
    create(:task, project:, status: :done)

    sign_in_as(user)
    click_link "Reports"

    expect(page).to have_text("Reports")
    expect(page).to have_text("Report Project")
  end
end
