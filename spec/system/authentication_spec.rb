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

    expect(page).to have_text("Welcome! You have signed up successfully.")
  end

  it "allows a user to sign in" do
    create(:user, email: "test@example.com", password: "password123")
    visit new_user_session_path
    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password123"
    click_button "Log in"

    expect(page).to have_text("Signed in successfully.")
  end
end
