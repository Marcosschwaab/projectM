FactoryBot.define do
  factory :custom_field_value do
    custom_field
    customizable { association(:task) }
    value { "Some value" }
  end
end
