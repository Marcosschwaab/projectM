class BackfillTaskProgress < ActiveRecord::Migration[8.0]
  def up
    Task.where(status: "done").where("progress IS NULL OR progress < 100").update_all(progress: 100)
    Task.where(status: "in_progress").where(progress: [nil, 0]).update_all(progress: 50)
    Task.where(status: "in_review").where(progress: [nil, 0]).update_all(progress: 80)
    Task.where(status: "todo").where(progress: [nil, 0]).update_all(progress: 10)
  end

  def down
  end
end
