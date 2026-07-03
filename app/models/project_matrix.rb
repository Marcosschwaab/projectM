class ProjectMatrix < ApplicationRecord
  belongs_to :project
  has_many :matrix_columns, -> { order(position: :asc) }, dependent: :destroy
  has_many :matrix_rows, -> { order(position: :asc) }, dependent: :destroy
  has_many :matrix_cells, through: :matrix_columns

  validates :name, presence: true
end
