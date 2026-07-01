FactoryBot.define do
  factory :activity_log do
    user
    organization
    action { "task_created" }
    trackable factory: :task
  end
end
