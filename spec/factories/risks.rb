FactoryBot.define do
  factory :risk do
    project
    owner factory: :user
    name { Faker::Lorem.sentence(word_count: 3) }
    description { Faker::Lorem.paragraph }
    probability { 3 }
    impact { 3 }
    status { :identified }
    mitigation_plan { Faker::Lorem.paragraph }
    contingency_plan { Faker::Lorem.paragraph }
  end
end