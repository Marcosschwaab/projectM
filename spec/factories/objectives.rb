FactoryBot.define do
  factory :objective do
    okr_cycle
    owner factory: :user
    title { Faker::Company.catch_phrase }
  end
end
