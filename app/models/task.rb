class Task < ApplicationRecord
  belongs_to :user

  enum :status, {
    todo: 0,
    in_progress: 1,
    completed: 2
  }

  enum :priority, {
    low: 0,
    medium: 1,
    high: 2
  }

  validates :title, presence: true
  validates :status, presence: true
  validates :priority, presence: true

  validate :due_date_cannot_be_in_past

  scope :by_status, ->(status) { where(status: status) if status.present? }
  scope :by_priority, ->(priority) { where(priority: priority) if priority.present? }
  scope :search, ->(q) {
    where("title ILIKE ?", "%#{q}%") if q.present?
  }

  private

  def due_date_cannot_be_in_past
    return if due_date.blank?
    errors.add(:due_date, "cannot be in the past") if due_date < Date.today
  end
end
