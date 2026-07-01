FactoryBot.define do
  factory :tag do
    organization
    name { Faker::Lorem.word }
    color { "#6366f1" }
  end
end
