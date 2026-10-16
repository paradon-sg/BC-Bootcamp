class Project < ApplicationRecord
  has_many :tasks, dependent: :destroy

  validates :name, presence: true

  broadcasts_refreshes_to ->(_) { "project-container" }
end
