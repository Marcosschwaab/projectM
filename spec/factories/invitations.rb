FactoryBot.define do
  factory :invitation do
    organization
    user
    email { Faker::Internet.unique.email }
    token { SecureRandom.hex(16) }
    role { :member }
  end
end
