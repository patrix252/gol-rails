class Board < ApplicationRecord
  validates_presence_of :generation, :rows, :cols, :data
  validates_numericality_of :generation, only_integer: true, greater_than_or_equal_to: 0
  validates_numericality_of :rows, :cols, only_integer: true, greater_than: 0, less_than_or_equal_to: 100
  validate :data_length_must_match_dimensions

  private

  def data_length_must_match_dimensions
    if data&.length != rows * cols
      errors.add(:data, "length must be equal to rows * cols")
    end
  end
end
