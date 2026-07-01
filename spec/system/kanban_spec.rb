require "rails_helper"

RSpec.describe "Kanban", type: :system do
  before { driven_by(:rack_test) }

  it "displays the kanban board" do
    user, organization = create_user_with_organization.values_at(:user, :organization)
    project = create(:project, organization:, name: "Kanban Project")
    create(:task, project:, title: "Design mockup", status: :todo)
    create(:task, project:, title: "Build feature", status: :in_progress)
    create(:task, project:, title: "Deploy to prod", status: :done)

    sign_in_as(user)
    click_link "Projects"
    click_link "Kanban Project"
    click_link "Kanban"

    expect(page).to have_text("Kanban")
    expect(page).to have_text("Design mockup")
    expect(page).to have_text("Build feature")
    expect(page).to have_text("Deploy to prod")
  end
end
