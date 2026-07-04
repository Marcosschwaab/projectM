class AddProgramToProjects < ActiveRecord::Migration[8.1]
  def change
    add_reference :projects, :program, null: true, foreign_key: true
  end
end
