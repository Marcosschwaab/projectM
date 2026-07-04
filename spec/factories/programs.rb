FactoryBot.define do
  factory :program do
    organization
    name { Faker::App.name + " Program" }
    description { Faker::Lorem.paragraph }
    status { :on_track }
    color { "#6366f1" }
  end
end
