FactoryBot.define do
  factory :key_result do
    objective
    title { Faker::Company.buzzword }
    target_value { 100 }
    current_value { 0 }
    unit { "%" }
  end
end
