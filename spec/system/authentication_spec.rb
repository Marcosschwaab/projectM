require "rails_helper"

RSpec.describe "Authentication", type: :system do
  before { driven_by(:rack_test) }

  it "allows a user to sign up" do
    visit new_user_registration_path
    fill_in "Name", with: "Test User"
    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password123"
    fill_in "Password confirmation", with: "password123"
    click_button "Sign up"

    expect(page).to have_text("Create an organization to get started.")
    expect(page).to have_text("New Organization")
  end

  it "allows a user to sign in" do
    user = create(:user)
    organization = create(:organization, name: "My Org")
    create(:organization_membership, user:, organization:, role: :admin)

    visit new_user_session_path
    fill_in "Email", with: user.email
    fill_in "Password", with: "password123"
    click_button "Sign in"

    expect(page).to have_text("Dashboard")
  end

  it "shows error with invalid credentials" do
    visit new_user_session_path
    fill_in "Email", with: "wrong@example.com"
    fill_in "Password", with: "wrong"
    click_button "Sign in"

    expect(page).to have_text(/Invalid.*(email|password)/i)
  end

  it "allows a user to sign out" do
    user = create(:user)
    organization = create(:organization)
    create(:organization_membership, user:, organization:, role: :admin)

    visit new_user_session_path
    fill_in "Email", with: user.email
    fill_in "Password", with: "password123"
    click_button "Sign in"

    expect(page).to have_text("Dashboard")

    click_button "Sign out"

    expect(page).to have_text("Sign in to ProjectM")
  end
end
