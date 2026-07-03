class MatrixColumn < ApplicationRecord
  belongs_to :project_matrix
  has_many :matrix_cells, dependent: :destroy

  validates :name, presence: true
end
