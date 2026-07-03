class MatrixCell < ApplicationRecord
  belongs_to :matrix_column
  belongs_to :matrix_row

  validates :value, presence: false
end
