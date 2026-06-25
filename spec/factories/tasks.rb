FactoryBot.define do
  factory :task do
    project
    title { Faker::Lorem.sentence(word_count: 5) }
    description { Faker::Lorem.paragraph }
    priority { :medium }
    status { :todo }
  end
end
