require "rails_helper"

RSpec.describe "Strategic Canvas", type: :system do
  before { driven_by(:rack_test) }

  it "updates the strategic canvas" do
    user, organization = create_user_with_organization.values_at(:user, :organization)
    project = create(:project, organization:, name: "Strategic Project")

    sign_in_as(user)
    click_link "Projects"
    click_link "Strategic Project"
    click_link "Strategic Canvas"

    expect(page).to have_text("Strategic Canvas")

    fill_in "strategic_canvas[problem]", with: "We need to grow revenue"
    fill_in "strategic_canvas[goal]", with: "Increase revenue by 20%"
    click_button "Save Canvas"

    expect(page).to have_text("Canvas updated.")
  end
end
