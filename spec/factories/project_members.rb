FactoryBot.define do
  factory :project_member do
    project
    user
    role { :member }
  end
end
