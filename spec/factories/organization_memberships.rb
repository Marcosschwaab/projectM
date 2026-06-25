FactoryBot.define do
  factory :organization_membership do
    user
    organization
    role { :member }
  end
end
