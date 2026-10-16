class Project < ApplicationRecord
  has_many :tasks, dependent: :destroy

  validates :name, presence: true

  broadcasts_to ->(_) { "project-container" }, target: "project-list"
end
