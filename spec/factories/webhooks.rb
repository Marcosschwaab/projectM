FactoryBot.define do
  factory :webhook do
    organization
    name { Faker::App.name }
    url { "https://hooks.example.com/#{SecureRandom.hex(8)}" }
    events { %w[task.created task.updated task.moved comment.created] }
    active { true }
  end
end
