class Task < ApplicationRecord
  belongs_to :user
  validates :title, presence: true
  validates :status, presence: true
  validate :due_date_cannot_be_in_past

  def due_date_cannot_be_in_past
    return if due_date.blank?
    errors.add(:due_date, "cannot be in the past") if due_date < Date.today
  end
end

