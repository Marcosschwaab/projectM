FactoryBot.define do
  factory :dashboard_widget do
    user
    widget_type { DashboardWidget::WIDGET_TYPES.sample }
    position { 0 }
    width { 1 }
    visible { true }
    settings { {} }
  end
end
