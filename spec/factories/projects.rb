FactoryBot.define do
  factory :project do
    organization
    name { Faker::App.name }
    description { Faker::Lorem.paragraph }
    priority { :medium }
    status { :on_track }
    color { "#6366f1" }
    icon { "folder" }
  end
end
