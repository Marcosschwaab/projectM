require "rails_helper"

RSpec.describe "Dashboard", type: :system do
  before { driven_by(:rack_test) }

  it "displays dashboard with stats" do
    user = create(:user)
    organization = create(:organization)
    create(:organization_membership, user:, organization:, role: :admin)
    project = create(:project, organization:, assignee: user, status: :on_track, name: "Active Project")

    sign_in_as(user)

    expect(page).to have_text("Dashboard")
    expect(page).to have_text("Active Projects")
    expect(page).to have_text("Active Project")
  end

  it "displays OKR progress when active cycle exists" do
    user = create(:user)
    organization = create(:organization)
    create(:organization_membership, user:, organization:, role: :admin)
    create(:okr_cycle, organization:, status: :active, title: "Q1 2026")

    sign_in_as(user)

    expect(page).to have_text("OKR Progress")
    expect(page).to have_text("Q1 2026")
  end

  it "shows create organization prompt when no organization" do
    user = create(:user)

    sign_in_as(user)

    expect(page).to have_text("Create an organization to get started.")
  end
end
