require "rails_helper"

RSpec.describe "OKR Cycles", type: :system do
  before { driven_by(:rack_test) }

  it "creates an OKR cycle" do
    user, organization = create_user_with_organization.values_at(:user, :organization)

    sign_in_as(user)
    click_link "OKRs"
    click_link "New Cycle"
    fill_in "Title", with: "Q1 2026"
    fill_in "Start Date", with: Date.current
    fill_in "End Date", with: 3.months.from_now
    click_button "Create cycle"

    expect(page).to have_text("OKR cycle created.")
    expect(page).to have_text("Q1 2026")
  end

  it "displays cycle details with objectives" do
    user, organization = create_user_with_organization.values_at(:user, :organization)
    cycle = create(:okr_cycle, organization:, title: "Q2 2026", status: :active)
    objective = create(:objective, okr_cycle: cycle, title: "Improve performance", owner: user)
    create(:key_result, objective:, title: "Reduce load time")

    sign_in_as(user)
    visit organization_okr_cycle_path(organization, cycle)

    expect(page).to have_text("Q2 2026")
    expect(page).to have_text("Improve performance")
    expect(page).to have_text("Reduce load time")
  end

  it "edits an OKR cycle" do
    user, organization = create_user_with_organization.values_at(:user, :organization)
    cycle = create(:okr_cycle, organization:, title: "Old Title")

    sign_in_as(user)
    visit edit_organization_okr_cycle_path(organization, cycle)
    fill_in "Title", with: "Updated Cycle"
    click_button "Update"

    expect(page).to have_text("OKR cycle updated.")
    expect(page).to have_text("Updated Cycle")
  end
end
