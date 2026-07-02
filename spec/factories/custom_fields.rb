FactoryBot.define do
  factory :custom_field do
    organization
    name { Faker::Lorem.word }
    field_type { "text" }
    required { false }
  end
end
