FactoryBot.define do
  factory :notification do
    recipient factory: :user
    organization
    actor factory: :user
    action { "task_assigned" }
    notifiable factory: :task
  end
end
