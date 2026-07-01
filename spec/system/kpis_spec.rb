require "rails_helper"

RSpec.describe "KPIs", type: :system do
  before { driven_by(:rack_test) }

  it "creates a KPI" do
    user, organization = create_user_with_organization.values_at(:user, :organization)
    project = create(:project, organization:, name: "Project X")

    sign_in_as(user)
    click_link "KPIs"
    click_link "New KPI"
    fill_in "Name", with: "Revenue Growth"
    fill_in "Target", with: 100
    fill_in "Current", with: 50
    click_button "Create KPI"

    expect(page).to have_text("KPI created.")
    expect(page).to have_text("Revenue Growth")
  end

  it "displays the KPIs index" do
    user, organization = create_user_with_organization.values_at(:user, :organization)
    project = create(:project, organization:, name: "Project X")
    create(:kpi, organization:, project:, owner: user, name: "Customer Satisfaction")

    sign_in_as(user)
    click_link "KPIs"

    expect(page).to have_text("Customer Satisfaction")
  end
end
