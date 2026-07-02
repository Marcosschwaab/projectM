FactoryBot.define do
  factory :time_entry do
    task
    user
    started_at { 1.hour.ago }
    ended_at { Time.current }
    duration { 60 }
    description { Faker::Lorem.sentence }
  end
end
