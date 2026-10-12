class Project < ApplicationRecord
  enum :status, { active: 0, archived: 1 }

  has_many :tasks, dependent: :destroy

  validates :name, presence: true
end
