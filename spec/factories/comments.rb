FactoryBot.define do
  factory :comment do
    task
    user
    content { Faker::Lorem.paragraph }
  end
end
