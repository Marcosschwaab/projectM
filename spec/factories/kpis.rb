FactoryBot.define do
  factory :kpi do
    organization
    project
    owner factory: :user
    name { Faker::Company.bs }
    target_value { 100 }
    current_value { 0 }
    unit { "%" }
    category { :strategic }
    frequency { :monthly }
  end
end
