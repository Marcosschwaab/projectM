class AddFinancialFieldsToProjects < ActiveRecord::Migration[8.1]
  def change
    add_column :projects, :proposal_investment_estimated, :decimal, precision: 15, scale: 2, default: 0.0
    add_column :projects, :project_investment_estimated, :decimal, precision: 15, scale: 2, default: 0.0
    add_column :projects, :budget_estimated, :decimal, precision: 15, scale: 2, default: 0.0
    add_column :projects, :budget_actual, :decimal, precision: 15, scale: 2, default: 0.0
    add_column :projects, :return_estimated, :decimal, precision: 15, scale: 2, default: 0.0
    add_column :projects, :return_actual, :decimal, precision: 15, scale: 2, default: 0.0
  end
end
