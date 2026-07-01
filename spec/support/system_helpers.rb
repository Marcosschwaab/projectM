module SystemHelpers
  def sign_in_as(user)
    visit new_user_session_path
    fill_in "Email", with: user.email
    fill_in "Password", with: "password123"
    click_button "Sign in"
  end

  def create_user_with_organization
    user = create(:user)
    organization = create(:organization)
    create(:organization_membership, user:, organization:, role: :admin)
    { user:, organization: }
  end
end

RSpec.configure do |config|
  config.include SystemHelpers, type: :system
end
