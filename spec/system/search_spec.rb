require "rails_helper"

RSpec.describe "Search", type: :system do
  before { driven_by(:rack_test) }

  it "finds projects and tasks" do
    user, organization = create_user_with_organization.values_at(:user, :organization)
    project = create(:project, organization:, name: "Marketing Site")

    sign_in_as(user)
    visit search_path(q: "Marketing")

    expect(page).to have_text("Search")
    expect(page).to have_text("Marketing Site")
  end

  it "shows no results for non-existent content" do
    user, organization = create_user_with_organization.values_at(:user, :organization)

    sign_in_as(user)
    visit search_path(q: "xyznonexistent")

    expect(page).to have_text("No results found")
  end
end
