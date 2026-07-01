FactoryBot.define do
  factory :okr_cycle do
    organization
    title { "#{Faker::Lorem.word} #{Faker::Number.between(from: 2020, to: 2030)}" }
    status { :draft }
    start_date { Date.current }
    end_date { 3.months.from_now }
  end
end
