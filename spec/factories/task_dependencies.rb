FactoryBot.define do
  factory :task_dependency do
    task factory: :task
    dependency factory: :task
  end
end
