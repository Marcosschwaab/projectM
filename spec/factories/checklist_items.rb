FactoryBot.define do
  factory :checklist_item do
    task
    content { Faker::Lorem.sentence(word_count: 3) }
  end
end
